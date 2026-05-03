ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

# Enable YJIT for better performance
ENV["RUBYOPT"] = "--yjit"

require "bundler/setup" # Set up gems listed in the Gemfile.
