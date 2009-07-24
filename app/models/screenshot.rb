require 'base64'
require 'zlib'

class Screenshot < ActiveRecord::Base
  include AuthorizationHelper

  has_one :url
  has_attachment :content_type => :image,
                 :max_size     => 2.megabytes,
                 :thumbnails   => { :small => Configuration.find_retry(:name => "screenshot.thumb.size", :namespace => "Screenshot").to_s },
                 :path_prefix  => Configuration.find_retry(:name => "screenshot.directory", :namespace => "Screenshot").to_s,
                 :partition    => true,
                 :storage      => :file_system

  validates_as_attachment

  # XXX: This method is overloaded from attachment_fu.rb in order to properly deal with data supplied from
  # outside normal controllers.  We assume the data is provided as a StringIO, which as been Base64 encoded
  # and Zlib compressed.
  #
  # This method handles the uploaded file object.  If you set the field name to uploaded_data, you don't need
  # any special code in your controller.
  #
  #   <% form_for :attachment, :html => { :multipart => true } do |f| -%>
  #     <p><%= f.file_field :uploaded_data %></p>
  #     <p><%= submit_tag :Save %>
  #   <% end -%>
  #
  #   @attachment = Attachment.create! params[:attachment]
  #
  # TODO: Allow it to work with Merb tempfiles too.
  def uploaded_data=(file_data)
    if file_data.is_a?(StringIO)
      self.content_type = 'image/png'
      self.filename = Digest::SHA1.hexdigest(rand.to_s) + '.png'
      file_data.rewind
      begin
        set_temp_data Zlib::Inflate.inflate(Base64.decode64(file_data.read))
      rescue
        # Log any failures.
        RAILS_DEFAULT_LOGGER.warn "Unable to save Screenshot data to: " + self.filename.to_s + " - " + $!.to_s
      end
    else
      return nil
    end
  end
end
