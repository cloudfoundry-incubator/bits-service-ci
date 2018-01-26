require 'spec_helper'
require 'pathname'
require_relative '../scripts/ops_file_updater'
require 'tempfile'


describe OpsFileUpdater do
  subject { OpsFileUpdater.new(ops_file) }
  let(:ops_file) { Pathname('spec/fixtures/bits-service.yml') }

  it 'exists' do
    expect(subject).to be
  end

  it 'lists all operations' do
    expect(subject.operations).to_not be_empty
    expect(subject.operations.size).to eq(12)
  end

  it 'finds an operation by path' do
    result = subject.find_by_path('/releases/-')
    expect(result).to be
    expect(result.size).to eq(1)
  end

  it 'serializes to a string' do
    target = StringIO.new
    subject.dump(target)
    expect(target.string).to_not be_empty
  end

  it 'serializes back into YAML' do
    parsed = parse_yaml(subject)
    expect(parsed).to be
    expect(parsed).to_not be_empty
  end

  it 'can serialize into a file' do |example|
    begin
      target_file = Tempfile.new(example.description)
      subject.dump(target_file)
      target_file.close

      loaded = YAML.load_file(target_file.path)
      expect(loaded).to_not be_empty
      expect(loaded.last['value']['version']).to eq('1.4.0')
    ensure
      target_file.unlink
    end
  end

  it 'serializes a modified object back into YAML' do
    operation = subject.find_by_path('/releases/-').first

    operation['value']['version'] = '1.5.0'

    changed = parse_yaml(subject)
    expect(changed.last['value']['version']).to eq('1.5.0')
  end

  it 'allows modification of the SHA' do
    operation = subject.find_by_path('/releases/-').first

    operation['value']['sha1'] = 'caa55a819046c289881883fabf0bb06c650ff9a6'

    changed = parse_yaml(subject)
    expect(changed.last['value']['sha1']).to eq('caa55a819046c289881883fabf0bb06c650ff9a6')
  end

  it 'allows modification of the url' do
    operation = subject.find_by_path('/releases/-').first

    operation['value']['url'] = 'http://example.com'

    changed = parse_yaml(subject)
    expect(changed.last['value']['url']).to eq('http://example.com')
  end

  def parse_yaml(updater)
    target = StringIO.new
    updater.dump(target)
    YAML.load(target.string)
  end
end
