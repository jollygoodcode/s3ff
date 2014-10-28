# Process `file_direct_url` synchronously in the foreground

class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # s3ff changes

  def avatar_direct_url=(value)
    self.attributes = {
      avatar: open(value),
      avatar_file_name: File.basename(value),
    }
  end
end
