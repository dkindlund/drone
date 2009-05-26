class JobAlert < ActiveRecord::Base
  include AuthorizationHelper

  belongs_to :job

  validates_presence_of :protocol, :address
  validates_length_of :protocol, :maximum => 255
  validates_length_of :address, :maximum => 255

  version 5
  index :protocol,             :limit => 500, :buffer => 0
  index :address,              :limit => 500, :buffer => 0
  index [:protocol, :address], :limit => 500, :buffer => 0
  index [:job_id, :id],        :limit => 500, :buffer => 0

  def to_label
    "#{protocol}:#{address}"
  end

  # Allow all admins to read any data.
  # Allow members to read only their own data.
  def authorized_for_read?
    return true if !existing_record_check?
    if !current_user.nil?
      if current_user.has_role?(:admin)
        return true
      else
        return !current_user.groups.map{|g| g.is_a?(Group) ? g.id : g}.index(self.job.group_id).nil?
      end
    else
      return false
    end
  end
end
