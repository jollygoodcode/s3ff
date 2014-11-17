require 's3_file_field'
require 's3ff/view_helper'
require 's3ff/model_helper'
require 's3ff/railtie'
require 's3ff/engine'

ActionView::Base.send(:include, S3FF::ViewHelper)
ActiveRecord::Base.send(:extend, S3FF::ModelHelper)

S3FileField::FormBuilder.class_eval do
  def s3_file_field_with_s3ff(method, options = {})
    direct_url_attr = "#{method}_direct_url"
    changes = @object.try(:changes) || {} # { attr => [old_value, new_value], ... }
    new_direct_url = (@object.class.column_names.include?(direct_url_attr) ?
      changes[direct_url_attr].try(:last) :
      @object.try(direct_url_attr))
    # set new_direct_url if such a db attribute exist & it has changed
    # but if it isn't a db attribute, try and use attr_reader
    if new_direct_url.present?
      # this means we're re-rendering :. we should prepopulate the s3ff fields to avoid re-uploading
      options[:data] ||= {}
      options[:data].merge!({
        s3ff: [{
          fieldname: "#{object_name.to_s}[#{direct_url_attr}]",
          unique_id: "#{object_name.to_s.parameterize}#{SecureRandom.hex}",
          result: {
            filename: changes["#{method}_file_name"].try(:last) || File.basename(new_direct_url),
            filesize: changes["#{method}_file_size"].try(:last),
            filetype: changes["#{method}_content_type"].try(:last),
            url: new_direct_url,
          },
        }],
      })
    end
    s3_file_field_without_s3ff(method, options)
  end
  alias_method_chain :s3_file_field, :s3ff
end
