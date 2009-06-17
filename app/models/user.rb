require 'digest/sha1'
require 'acts_as_ferret'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  include AuthorizationHelper

  has_and_belongs_to_many :roles
  has_and_belongs_to_many :groups

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message
  validates_length_of       :name,     :within => 2..100

  validates_length_of       :organization, :within => 2..100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  version 5
  index :login,           :limit => 500, :buffer => 0
  index :name,            :limit => 500, :buffer => 0
  index :organization,    :limit => 500, :buffer => 0
  index :email,           :limit => 500, :buffer => 0
  index :state,           :limit => 500, :buffer => 0
  index :activation_code, :limit => 500, :buffer => 0
  index :remember_token,  :limit => 500, :buffer => 0
  index :created_at,      :limit => 500, :buffer => 0
  index :updated_at,      :limit => 500, :buffer => 0
  index :activated_at,    :limit => 500, :buffer => 0
  index :deleted_at,      :limit => 500, :buffer => 0

  after_create :set_group

  acts_as_ferret( { :fields => [:name], :remote => true } )

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :organization, :password, :password_confirmation

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # has_role? simply needs to return true or false whether a user has a role or not.
  # "admin" roles return true always
  def has_role?(role_in_question)
    @_list ||= self.roles.collect(&:name)
    return true if @_list.include?("admin")
    (@_list.include?(role_in_question.to_s) )
  end

  # Allow all admins to read any data.
  # Allow members to read only their own data.
  def authorized_for_read?
    return true if !existing_record_check?
    if !current_user.nil?
      if current_user.has_role?(:admin)
        return true
      else
        return (current_user.has_role?(:member) && ((self.id == current_user.id) || (self.organization == current_user.organization)))
      end
    else 
      return false
    end
  end

  # Allow all admins to update any data.
  # TODO: Allow members to update only their own data.
  def authorized_for_update?
    return (!current_user.nil? && current_user.has_role?(:admin))
  end

  # Allow all admins to destroy any data.
  def authorized_for_destroy?
    return (!current_user.nil? && current_user.has_role?(:admin))
  end

  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

  private

  # Sets the primary group of the User, by using the organization
  # name as a basis.
  def set_group
    if (self.organization.to_s.length > 0)
      group = Group.find_or_create_by_name(self.organization.to_s)
      self.groups << group
    end
  end
end
