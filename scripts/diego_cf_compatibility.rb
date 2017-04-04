require 'csv'

class Compatibility
  def self.from(io)
    new(CSV.parse(io.read, headers: true, converters: :all))
  end

  def initialize(csv)
    @csv = csv
  end

  def cf_release(sha)
    @csv.select{|row| row['cf-release-commit-sha'] == sha }
  end
end
