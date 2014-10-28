if defined?(S3FileField) && ENV['AWS_KEY']
  cdn_hostname = ENV.fetch('CDN_HOSTNAME') { ENV['S3_BUCKET'] && "#{ENV['S3_BUCKET']}.s3.amazonaws.com" }
  S3FileField.config do |c|
    c.access_key_id = ENV['AWS_KEY']
    c.secret_access_key = ENV['AWS_SECRET']
    c.bucket = ENV['S3_BUCKET']
    c.region = ENV['S3_BUCKET_REGION'] || 'us-west-2'
    c.url = "//#{cdn_hostname}" if cdn_hostname # S3 API endpoint (optional), eg. "https://#{c.bucket}.s3.amazonaws.com/"
    # c.acl = "public-read"
    # c.expiration = 10.hours.from_now.utc.iso8601
    # c.max_file_size = 100.megabytes
    # c.conditions = []
    # c.key_starts_with = 'uploads/
    # c.ssl = true # if true, force SSL connection
  end

elsif defined?(S3FileField) # for when no S3 is configured, fallback to regular `file_field`
  S3FileField::FormBuilder.class_eval do
    def s3_file_field(method, options = {})
      @template.file_field(@object_name, method, options)
    end
  end
end
