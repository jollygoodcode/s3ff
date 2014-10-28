# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3ff/version'

Gem::Specification.new do |gem|
  gem.authors       = ['Chew Choon Keat']
  gem.email         = ['choonkeat@gmail.com']
  gem.description   = 'Direct S3 upload using CORS with s3_file_field + paperclip'
  gem.summary       = 'Direct S3 upload using CORS with s3_file_field + paperclip'
  gem.homepage      = 'https://github.com/jollygoodcode/s3ff'

  gem.files         = Dir['{lib,app,vendor}/**/*'] + ['README.md']
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 's3ff'
  gem.require_paths = ['lib']
  gem.version       = S3FF::VERSION
  gem.license       = 'MIT'

  gem.add_dependency 's3_file_field', '>= 1.3.0'
  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
