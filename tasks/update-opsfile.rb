#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'
require_relative 'ops_file_updater.rb'

FileUtils.cp_r('cf-deployment/.', 'cf-deployment-updated')

ops_file_path = 'operations/bits-service/use-bits-service.yml'
ops_file = Pathname('cf-deployment') / ops_file_path

updater = OpsFileUpdater.new(ops_file)
operation = updater.find_by_path('/releases/-').first
version = File.read('release-version/version').chomp

operation['value']['sha1'] = File.read('digests/digest.txt').chomp
operation['value']['version'] = version
operation['value']['url'] = "https://github.com/cloudfoundry-incubator/bits-service-release/releases/download/#{version}/bits-service-#{version}.tgz"

puts "Updating #{ops_file_path} with:"
%w(sha1 version url).each do |key|
  puts "  #{key} => #{operation['value'][key]}"
end

output_file = Pathname('cf-deployment-updated') / ops_file_path

File.open(output_file, 'w') do |writable|
  updater.dump(writable)
end
