# S3FF

Using `s3_file_field` with `paperclip`

## Install

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



### License

This repository is MIT-licensed.
