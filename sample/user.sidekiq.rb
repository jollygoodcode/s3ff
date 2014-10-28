# using Sidekiq to process `avatar_direct_url` in the background

class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # s3ff changes, where `avatar_direct_url` is an actual database column

  after_save :delay_download_direct_url, if: proc { avatar_direct_url.present? && avatar_direct_url_changed? }

  def delay_download_direct_url
    self.class.delay.download_direct_url(id, avatar_direct_url)
  end

  def self.download_direct_url(user_id, avatar_direct_url)
    User.find(user_id).update_attributes(
      avatar: open(avatar_direct_url),
      avatar_file_name: File.basename(avatar_direct_url),
    )
  end
end
