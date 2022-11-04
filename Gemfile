source 'https://rubygems.org'
gemspec

logstash_path = ENV['LOGSTASH_PATH'] || '/usr/local/Cellar/logstash/8.5.0/libexec'

if Dir.exist?(logstash_path)
  gem 'logstash-core', :path => "#{logstash_path}/logstash-core"
  gem 'logstash-core-plugin-api', :path => "#{logstash_path}/logstash-core-plugin-api"
end

