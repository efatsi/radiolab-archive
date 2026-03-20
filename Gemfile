source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"
gem "rails", "~> 7.0.2", ">= 7.0.2.4"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 3.3.1"
gem "bootsnap", require: false
gem "concurrent-ruby", "< 1.3"

gem "devise"
gem "awesome_print"
gem "sprig"
gem "heroicon"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  gem "web-console"
  gem "pry-rails"
end


gem "dockerfile-rails", ">= 1.2", :group => :development
