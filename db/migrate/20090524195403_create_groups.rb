class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
    end

    # generate the join table
    create_table "groups_users", :id => false do |t|
      t.integer "group_id", "user_id"
    end

    add_index :groups, :name, :unique => true
    add_index "groups_users", "group_id"
    add_index "groups_users", "user_id"

    # generate the initial groups
    User.find(:all).each do |user|
      if (!user.organization.nil? && (user.organization.to_s.length > 0))
        group = Group.find_by_name(user.organization.to_s)
        if group.nil?
          group = Group.new(:name => user.organization.to_s)
          group.save!
        end
        user.groups << group
      end
    end

    # update job_source table
    add_column :job_sources, :group_id, :integer, :default => nil
    add_index :job_sources, :group_id
    execute "ALTER TABLE `job_sources` DROP INDEX `by_unique_name_and_protocol`"
    add_index :job_sources, [:name, :protocol, :group_id], :unique => true, :name => "by_unique_name_and_protocol_and_group"

    # associate job_sources with corresponding groups through user names
    JobSource.find(:all).each do |job_source|
      # try to find an exact user match
      user = User.find_by_name(job_source.name)
      if (!user.nil?)
        group = user.groups.first
        if (!group.nil?)
          job_source.group = group
          job_source.save!
        end
      else
        # no exact match was found, so
        # construct the query string
        query_string = job_source.name.to_s.split(' ').last
        if (query_string.length > 0)
          users = User.find_with_ferret(query_string)
          if (users.size > 0)
            group = users.first.groups.first
            if (!group.nil?)
              job_source.group = group
              job_source.save!
            end
          end
        end
      end
    end

    # update jobs table
    add_column :jobs, :group_id, :integer, :default => nil
    add_index :jobs, :group_id

    # associate jobs with corresponding groups through job_source
    JobSource.find(:all).each do |job_source|
      if (!job_source.group.nil?)
        Job.update_all("group_id = " + job_source.group_id.to_s, [ "job_source_id = ?", job_source.id.to_s ])
      end
    end

    # update urls table
    add_column :urls, :group_id, :integer, :default => nil
    add_index :urls, :group_id

    # associate urls with corresponding groups through jobs
    Job.find(:all).each do |job|
      if (!job.group.nil?)
        Url.update_all("group_id = " + job.group_id.to_s, [ "job_id = ?", job.id.to_s ])
      end
    end
  end

  def self.down
    remove_index :urls, :group_id
    remove_column :urls, :group_id

    remove_index :jobs, :group_id
    remove_column :jobs, :group_id

    execute "ALTER TABLE `job_sources` DROP INDEX `by_unique_name_and_protocol_and_group`"
    remove_index :job_sources, :group_id
    add_index :job_sources, [:name, :protocol], :unique => true, :name => "by_unique_name_and_protocol"
    remove_column :job_sources, :group_id

    drop_table "groups_users"
    drop_table :groups
  end
end
