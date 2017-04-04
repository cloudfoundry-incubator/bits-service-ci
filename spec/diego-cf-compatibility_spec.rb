require 'spec_helper'
require 'pathname'
require_relative '../scripts/diego_cf_compatibility'

describe Compatibility do
  subject(:compatibility) { Compatibility.from(Pathname('spec/fixtures/compatibility-v9.csv')) }
  let(:compatible_releases) { compatibility.cf_release(sha)}

  context 'a valid cf-release SHA' do
    let(:sha){'36da4e3716a902de288a07abbba94e4ba200ba46'}

    it 'returns the right number of compatible releases' do
      expect(compatible_releases.size).to eq(2)
    end

    it 'all compatible releases use the expected Diego version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['diego-release-version']).to eq('1.8.0')
      end
    end

    it 'all compatible releases use the expected garden-runc-release version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['garden-runc-release-version']).to eq('1.2.0')
      end
    end

    it 'all compatible releases use the expected cflinuxfs2-rootfs-release version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['cflinuxfs2-rootfs-release-version']).to eq('1.51.0')
      end
    end
  end

  context 'another valid cf-release SHA' do
    let(:sha){'e9fde0704960e306cd1c8a8f6e3ff3a2e0f08eb0'}

    it 'returns the right number of compatible releases' do
      expect(compatible_releases.size).to eq(3)
    end

    it 'all compatible releases use the expected Diego version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['diego-release-version']).to eq('1.11.0')
      end
    end

    it 'all compatible releases use the expected garden-runc-release version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['garden-runc-release-version']).to eq('1.3.0')
      end
    end

    it 'all compatible releases use the expected cflinuxfs2-rootfs-release version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['cflinuxfs2-rootfs-release-version']).to eq('1.60.0')
      end
    end
  end

  context 'a valid cf-release with multiple compatible Diego versions' do
    let(:sha){'36a8a2417838f7311453ac5334f86976fbb3876d'}

    it 'returns the right number of compatible releases' do
      expect(compatible_releases.size).to eq(2)
    end

    it 'all compatible releases use the expected Diego version' do
      expect(compatible_releases.first['diego-release-version']).to eq('1.8.1')
      expect(compatible_releases.last['diego-release-version']).to eq('1.9.0')
    end

    it 'all compatible releases use the expected garden-runc-release version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['garden-runc-release-version']).to eq('1.2.0')
      end
    end

    it 'all compatible releases use the expected cflinuxfs2-rootfs-release version' do
      compatible_releases.each do |compatible_release|
        expect(compatible_release['cflinuxfs2-rootfs-release-version']).to eq('1.53.0')
      end
    end
  end

  it 'sorts semantic versions correctly' do
    latest = %w(1.11 1.0 1.1).uniq.sort.last
    expect(latest).to eq('1.11')
  end
end
