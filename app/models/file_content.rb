require 'md5'
require 'sha1'
require 'base64'
require 'zlib'

class FileContent < ActiveRecord::Base
  include AuthorizationHelper

  has_many :process_files

  validates_presence_of :md5, :sha1, :size, :mime_type
  validates_length_of :md5, :maximum => 255
  validates_length_of :sha1, :maximum => 255
  validates_length_of :mime_type, :maximum => 255
  validates_numericality_of :size, :greater_than_or_equal_to => 0
  validates_uniqueness_of :md5, :scope => [:sha1, :size]

  version 8
  index :md5,                 :limit => 500, :buffer => 0
  index :sha1,                :limit => 500, :buffer => 0
  index :mime_type,           :limit => 500, :buffer => 0
  index :data,                :limit => 500, :buffer => 0

  before_validation_on_create :extract_data

  def to_label
    "sha1: #{sha1}"
  end

  private

  def extract_data()
    if (!self.data.nil?)
      data = self.data.to_s
      if (self.md5.nil?)
        self.md5 = Digest::MD5.hexdigest(Zlib::Inflate.inflate(Base64.decode64(data)))
      end
      if (self.sha1.nil?)
        self.sha1 = Digest::SHA1.hexdigest(Zlib::Inflate.inflate(Base64.decode64(data)))
      end
      filename = Configuration.find_retry(:name => "file_content.directory", :namespace => "FileContent").to_s + '/' +
                 self.md5.to_s

      # Attempt to write the file content out to the directory.
      self.data = nil
      if (!File.exists?(filename + ".zip"))
        begin
          open(filename, 'wb') do |file|
            file.print Zlib::Inflate.inflate(Base64.decode64(data))
          end

          # Once written, next we need to create the password protected ZIP file.
          if (!system("zip -P '" +
                      Configuration.find_retry(:name => "file_content.zip.password", :namespace => "FileContent").to_s + 
                      "' -emj " + filename.to_s + ".zip " + filename.to_s))
            raise "ZIP operation failed."
          end

          # Only update the filename reference if the save was successful.
          self.data = filename.to_s + ".zip"
        rescue
          # Log any failures.
          RAILS_DEFAULT_LOGGER.warn "Unable to save FileContent data to: " + filename.to_s + ".zip - " + $!.to_s
        end
      else
        # ZIP file already exists, so just set the reference accordingly.
        self.data = filename.to_s + ".zip"
      end
    end
  end
end
