require 's3_file_field'
require 's3ff/view_helper'
require 's3ff/railtie'
require 's3ff/engine'

ActionView::Base.send(:include, S3FF::ViewHelper)

S3FileField::FormBuilder.class_eval do
  def s3_file_field_with_s3ff(method, options = {})
    changes = @object.try(:changes) || {} # { attr => [old_value, new_value], ... }
    if new_direct_url = changes["#{method}_direct_url"].try(:last)
      # if *_direct_url_changed? it means we're re-rendering
      # :. we should prepopulate the s3ff fields to avoid re-uploading
      options[:data] ||= {}
      options[:data].merge!({
        s3ff: {
          files: [{
            unique_id: "#{@object_name.parameterize}#{SecureRandom.hex}",
          }],
          result: {
            filename: changes["#{method}_file_name"].try(:last) || File.basename(new_direct_url),
            filesize: changes["#{method}_file_size"].try(:last),
            filetype: changes["#{method}_content_type"].try(:last),
            url: new_direct_url,
          }
        }
      })
    end
    s3_file_field_without_s3ff(method, options)
  end
  alias_method_chain :s3_file_field, :s3ff
end
