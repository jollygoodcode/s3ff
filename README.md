# S3FF

Using [s3_file_field][] with [paperclip][].

[s3_file_field]: https://github.com/sheerun/s3_file_field
[paperclip]: https://github.com/thoughtbot/paperclip

## Install

### 0. Add initializer for s3_file_field:

```ruby
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
```

### 1. Add javascript

in your application.js

```
//= require s3ff
```

### 2. Change `file_field` input to use `s3_file_field`

```
= form_for :user do |f|
  = f.s3_file_field :avatar
```

or if you're using `simple_form`

```
= simple_form_for :user do |f|
  = f.input :avatar do
    = f.s3_file_field :avatar, :class => "form-control"
```

### 3. Add footer

```
= include_s3ff_templates
```

NOTE: Feel free to modify & render the templates manually, but keep the `s3ff_` prefixed CSS classes for our javascript to work properly.

## What will happen

To illustate, if you have a file field like this

```
<input type="file" name="user[avatar]">
```

When `s3ff` kicks in, it would upgrade the field to a `s3_file_field`. When your user chooses a file, it will be uploaded, with a progress indicator, directly into your S3 bucket (see `s3_file_field` gem for configuration). Your `form` will be disabled during the upload and re-enabled once upload completes. After this process, 4 new hidden form fields will be attached to your form:

```
<input type="file" name="user[avatar_direct_url]" value="https://....">
<input type="file" name="user[avatar_file_name]" value="face.png">
<input type="file" name="user[avatar_file_size]" value="162534">
<input type="file" name="user[avatar_content_type]" value="image/png">
```

## Code changes to your app

`s3ff` designed to minimize moving parts and code changes to your Rails app - all it does is give you 4 form fields in return for every direct s3 file upload that happened in your user's browser.

How you deal with these form fields are entirely up to you. Here's a simple way:

#### 1. Edit strong parameters

If your controller was specifying

```
params.require(:user).permit(:avatar)
```

It would need to be changed to accept the new form fields

```
params.require(:user).permit(:avatar,
  :avatar_direct_url,
  :avatar_file_name,
  :avatar_file_size,
  :avatar_content_type
)
```

#### 2. Upgrade model to also accept direct url

If your model was originally

```
class User < ActiveRecord::Base
  has_attached_file :avatar
end
```

Download the file from S3 when given `avatar_direct_url`. This leave all your existing Paperclip code and logic unchanged.

```
class User < ActiveRecord::Base
  has_attached_file :avatar

  attr_accessor :avatar_direct_url
  def avatar_direct_url=(value)
    self.avatar = open(value) if value.present?
  end
end
```

## License

This repository is MIT-licensed, see [LICENSE](LICENSE).
