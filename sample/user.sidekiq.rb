# using Sidekiq to process `avatar_direct_url` in the background

class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # s3ff changes, a virtual attribute `avatar_direct_url` will be added
  download_from_direct_url_with_delay :avatar
end
