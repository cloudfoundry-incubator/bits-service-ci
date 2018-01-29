#!/usr/bin/env ruby

require 'fileutils'
require_relative 'ops_file_updater.rb'

FileUtils.cp_r('cf-deployment/.', 'cf-deployment-updated', verbose: true)

ops_file = File.new('cf-deployment/operations/experimental/bits-service.yml')
updater = OpsFileUpdater.new(ops_file)
operation = updater.find_by_path('/releases/-').first
version = File.read('release-version/version').chomp

operation['value']['sha1'] = File.read('digests/digest.txt').chomp
operation['value']['version'] = version
operation['value']['url'] = "https://github.com/cloudfoundry-incubator/bits-service-release/releases/download/#{version}/bits-service-#{version}.tgz"

output_file = File.new('cf-deployment-updated/operations/experimental/bits-service.yml')

File.open(output_file, 'w') do |writable|
  updater.dump(writable)
end
