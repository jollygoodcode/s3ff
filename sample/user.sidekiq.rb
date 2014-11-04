# using Sidekiq to process `avatar_direct_url` in the background

class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # s3ff changes, where `avatar_direct_url` is either a virtual attribute or database column
  download_from_direct_url_with_delay :avatar
end
