# using DelayedJob to process `avatar_direct_url` in the background

class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # s3ff changes, where `avatar_direct_url` is an actual database column

  after_save :download_direct_url, if: -> { avatar_direct_url.present? && avatar_direct_url_changed? }

  def download_direct_url
    update_attributes(
      avatar: open(avatar_direct_url),
      avatar_file_name: File.basename(avatar_direct_url),
    )
  end

  handle_asynchronously :download_direct_url
end
