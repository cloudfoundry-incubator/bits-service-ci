require 'yaml'

version = ENV['VERSION']
sha1 = ENV['SHA1']
source_config_path = "#{ENV['BITS_OPSFILE']}"
tmp_config_path = "#{ENV['BITS_OPSFILE_TMP']}"

source_config = YAML.load_file(source_config_path)

source_config.each do | section |
    unless section["value"]["version"] && section["value"]["sha1"] && section["value"]["url"] 
        next
    end
    puts section["value"]["version"] = version
    puts section["value"]["sha1"] = sha1
    puts section["value"]["url"] = "https://github.com/cloudfoundry-incubator/bits-service-release/releases/download/#{version}/bits-service-#{version}.tgz"
end

File.open(tmp_config_path, 'w+') {|f| f.write source_config.to_yaml }
