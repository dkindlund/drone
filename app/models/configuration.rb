class Configuration < ActiveRecord::Base

  validates_presence_of :name, :value, :namespace
  validates_length_of :name, :maximum => 255
  validates_length_of :value, :maximum => 255
  validates_length_of :namespace, :maximum => 255
  validates_uniqueness_of :name, :scope => [:value, :namespace]

  def to_label
    "#{namespace}_#{name}"
  end

  # Get values out of the Configurations table.
  #
  # Get accepts two arguments:
  #
  # * <tt>:name</tt>: The name of the variable to look for.
  # * <tt>:namespace</tt>: The namespace to search within.
  #
  # If any configuration entry contains a matching name and
  # namespace, then the corresponding value of the first
  # match is returned.
  #
  # If no match is found, then it will try to return the
  # first matching :name entry, without a :namespace
  #
  # Otherwise, if not match is found, nil will be returned.
  def self.get(args = {})
    obj = Configuration.find(:first, :conditions => args)
    if obj.nil?
      args.delete(:namespace) 
      obj = Configuration.find(:first, :conditions => args)
    end
    return obj.nil? ? nil : obj.value
  end

end
