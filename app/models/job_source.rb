class JobSource < ActiveRecord::Base
  include AuthorizationHelper

  has_many :jobs
  belongs_to :group

  validates_presence_of :name, :protocol
  validates_length_of :name, :maximum => 255
  validates_length_of :protocol, :maximum => 255
  validates_uniqueness_of :name, :scope => [:protocol, :group_id]

  version 9
  index :name,                         :limit => 500, :buffer => 0
  index :protocol,                     :limit => 500, :buffer => 0
  index [:name, :protocol],            :limit => 500, :buffer => 0
  index :group_id,                     :limit => 500, :buffer => 0
  index [:group_id, :id],              :limit => 500, :buffer => 0
  index [:name, :protocol, :group_id], :limit => 500, :buffer => 0
  
  before_create :set_group

  def to_label
    "#{name}"
  end

  # Allow all admins to read any data.
  # Allow members to read only their own data.
  def authorized_for_read?
    return true if !existing_record_check?
    if !current_user.nil?
      if current_user.has_role?(:admin)
        return true
      else
        return !current_user.groups.map{|g| g.is_a?(Group) ? g.id : g}.index(self.group_id).nil?
      end
    else
      return false
    end
  end

  private

  def set_group
    if (!current_user.nil? && self.group.nil?)
      self.group = current_user.groups.first
    end
  end
end
