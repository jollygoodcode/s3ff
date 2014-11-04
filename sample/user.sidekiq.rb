# using Sidekiq to process `avatar_direct_url` in the background

class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # s3ff changes, where `avatar_direct_url` is either a virtual attribute or database column
  attr_accessor :avatar_direct_url
  after_save :delay_download_direct_url, if: proc { avatar_direct_url.present? }

  def delay_download_direct_url
    self.class.delay.download_direct_url(id, avatar_direct_url)
  end

  def self.download_direct_url(instance_id, avatar_direct_url)
    open(avatar_direct_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |file|
      find(instance_id).update(
        avatar: file,
        avatar_file_name: File.basename(avatar_direct_url),
      )
    end
  end
end
