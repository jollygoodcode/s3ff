# S3FF

Using [s3_file_field][] with [paperclip][].

[s3_file_field]: https://github.com/sheerun/s3_file_field
[paperclip]: https://github.com/thoughtbot/paperclip

## Installation

Add this line to your application's Gemfile:

    gem 's3ff'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install s3ff

## Usage

### 1. Configure s3_file_field

add a config like `sample/config_s3_file_field.rb` into your Rails `config/initializers/` directory

### 2. Add javascript

in your application.js

```
//= require s3ff
```

### 3. Change `file_field` input to use `s3_file_field`

``` haml
= form_for :user do |f|
  = f.s3_file_field :avatar
```

or if you're using `simple_form`

``` haml
= simple_form_for :user do |f|
  = f.input :avatar do
    = f.s3_file_field :avatar, :class => "form-control"
```

### 4. Add footer

``` haml
= include_s3ff_templates
```

NOTE: Feel free to modify & render the templates manually, but keep the `s3ff_` prefixed CSS classes for our javascript to work properly.

## What will happen

To illustate, if you have a file field like this

``` html
<input type="file" name="user[avatar]">
```

When `s3ff` kicks in, it would upgrade the field to a `s3_file_field`. When your user chooses a file, it will be uploaded, with a progress indicator, directly into your S3 bucket (see `s3_file_field` gem for configuration). Your `form` will be disabled during the upload and re-enabled once upload completes. After this process, a new hidden form field will be attached to your form:

``` html
<input type="file" name="user[avatar_direct_url]" value="https://....">
```

## Code changes to your app

`s3ff` designed to minimize moving parts and code changes to your Rails app - all it does is give you new hidden form fields in return for every direct s3 file upload that happened in your user's browser.

How you deal with these form fields are entirely up to you. Here's a simple way:

#### 1. Edit strong parameters

If your controller was specifying

``` ruby
params.require(:user).permit(:avatar)
```

It would need to be changed to accept the new form fields

``` ruby
params.require(:user).permit(:avatar, :avatar_direct_url)
```

#### 2. Upgrade model to also accept direct url

If your model was originally

``` ruby
class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
end
```

Download the file from S3 when given `avatar_direct_url`. This leaves all your existing Paperclip code and logic unchanged.

``` ruby
class User < ActiveRecord::Base
  has_attached_file :avatar
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  # s3ff changes

  def avatar_direct_url=(value)
    self.attributes = {
      avatar: open(value),
      avatar_file_name: File.basename(value),
    }
  end
end
```

#### CAVEAT

It isn't ideal to handle your attachment processing synchronously during the web request. For usage with `Sidekiq` or `DelayedJob`, look at the reference code in `sample/user.*.rb`


## Contributing

1. Fork it ( http://github.com/jollygoodcode/s3ff/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

This repository is MIT-licensed, see [LICENSE](LICENSE).
