require 'yaml'

class OpsFileUpdater
  attr_reader :operations

  def initialize(io)
    @operations = YAML.load(io.read)
  end

  def find_by_path(path)
    @operations.select{|operation|
      operation['path'] == path
    }
  end

  def dump(io)
    YAML.dump(@operations, io)
  end
end
