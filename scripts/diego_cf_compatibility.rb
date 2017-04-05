require 'csv'

class Compatibility
  def self.from(io)
    new(CSV.parse(io.read, headers: true, converters: :all))
  end

  def initialize(csv)
    @csv = csv
  end

  def with_cf_release(commit_sha)
    @csv.select{|row| row['cf-release-commit-sha'] == commit_sha }
  end

  def latest_cf_release
    @csv.sort_by{|row| row['date']}.last
  end
end
