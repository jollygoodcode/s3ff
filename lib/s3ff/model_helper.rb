module S3FF
  module ModelHelper
    def download_from_direct_url_with_delay(attr_name)
      if self.respond_to?(:delay)
        self.class_eval <<-EOM
          attr_accessor :#{attr_name}_direct_url
          after_save :delay_s3ff_download_direct_url, if: proc { #{attr_name}_direct_url.present? }

          def delay_s3ff_download_direct_url
            self.class.delay.s3ff_download_direct_url(id, #{attr_name}_direct_url)
          end

          def self.s3ff_download_direct_url(instance_id, #{attr_name}_direct_url)
            open(#{attr_name}_direct_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |file|
              find(instance_id).update(
                #{attr_name}: file,
                #{attr_name}_file_name: File.basename(#{attr_name}_direct_url),
              )
            end
          end
        EOM
      elsif self.respond_to?(:handle_asynchronously)
        self.class_eval <<-EOM
          after_save :s3ff_download_direct_url, if: -> { #{attr_name}_direct_url.present? && #{attr_name}_direct_url_changed? }

          def s3ff_download_direct_url
            open(#{attr_name}_direct_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE) do |file|
              update(
                #{attr_name}: file,
                #{attr_name}_file_name: File.basename(#{attr_name}_direct_url),
              )
            end
          end

          handle_asynchronously :s3ff_download_direct_url
        EOM
      else
        raise NotImplementedError('download_from_direct_url_with_delay only supports delayed_job or sidekiq delayed extension')
      end
    end
  end
end
