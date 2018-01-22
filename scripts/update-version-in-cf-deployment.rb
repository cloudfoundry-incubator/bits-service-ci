require 'yaml'

version = ENV['VERSION']
sha1 = ENV['SHA1']
source_config_path = "#{ENV['BITS_OPSFILE']}"
tmp_config_path = "#{ENV['BITS_OPSFILE_TMP']}"

File.open(source_config_path)
# source_config = YAML.load_file('/Users/norman/Developer/workspace/cloudfoundry/cf-deployment-petergtz/operations/experimental/bits-service.yml')
source_config = YAML.load_file(source_config_path)

source_config.each do | section |
    puts section["type"]
    puts section["path"]
    unless section["value"]["version"] && section["value"]["sha1"] && section["value"]["url"] 
        next
    end
    puts section["value"]["version"] = version
    puts section["value"]["sha1"] = sha1
    puts section["value"]["url"] = "https://github.com/cloudfoundry-incubator/bits-service-release/releases/download/#{version}/bits-service-#{version}.tgz"
end

# File.open("/Users/norman/Developer/workspace/cloudfoundry/cf-deployment-petergtz/operations/experimental/bits-service_1.yml", "r+"){|f| YAML.dump(source_config.to_yaml, f)}

#File.open('/Users/norman/Developer/workspace/cloudfoundry/cf-deployment-petergtz/operations/experimental/bits-service_1.yml', 'w') {|f| f.write source_config.to_yaml }
File.open(tmp_config_path, 'w+') {|f| f.write source_config.to_yaml }
