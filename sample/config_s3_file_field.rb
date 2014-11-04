if defined?(S3FileField) && ENV['AWS_KEY']
  S3FileField.config do |c|
    c.access_key_id = ENV['AWS_KEY']
    c.secret_access_key = ENV['AWS_SECRET']
    c.bucket = ENV['S3_BUCKET']
    c.url = ENV['CDN_URL_PREFIX'] if ENV['CDN_URL_PREFIX'].present? # S3 API endpoint (optional), eg. "https://#{bucket}.s3.amazonaws.com/"
    # c.region = 's3-us-middle-3' # note the 's3-' prefix; defaults to 's3' US Standard
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
