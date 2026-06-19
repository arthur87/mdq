# frozen_string_literal: true

require 'mdq'
require 'mdq/discovery'

RSpec.describe Mdq::Discovery do
  let(:discovery) { Mdq::Discovery.new }

  it 'discovery k1000' do
    k = 1000.0
    expect(discovery.send(:number_to_human_size, 1, k)).to eq '1.0 B'
    expect(discovery.send(:number_to_human_size, 1000, k)).to eq '1000.0 B'
    expect(discovery.send(:number_to_human_size, 1001, k)).to eq '1.0 KB'
    expect(discovery.send(:number_to_human_size, 123_456_789, k)).to eq '123.46 MB'
    expect(discovery.send(:number_to_human_size, 128_000_000_000, k)).to eq '128.0 GB'
  end

  it 'discovery k1024' do
    k = 1024.0
    expect(discovery.send(:number_to_human_size, 1, k)).to eq '1.0 B'
    expect(discovery.send(:number_to_human_size, 1000, k)).to eq '1000.0 B'
    expect(discovery.send(:number_to_human_size, 1001, k)).to eq '1001.0 B'
    expect(discovery.send(:number_to_human_size, 123_456_789, k)).to eq '117.74 MB'
    expect(discovery.send(:number_to_human_size, 128_000_000_000, k)).to eq '119.21 GB'
  end

  describe '#skip_device?' do
    context 'when physical device' do
      let(:physical) { true }

      it 'returns false if is_physical is true' do
        expect(discovery.send(:skip_device?, physical, true, true)).to be false
        expect(discovery.send(:skip_device?, physical, true, false)).to be false
      end

      it 'returns true if is_physical is false' do
        expect(discovery.send(:skip_device?, physical, false, true)).to be true
        expect(discovery.send(:skip_device?, physical, false, false)).to be true
      end
    end

    context 'when simulated device' do
      let(:physical) { false }

      it 'returns false if is_simulated is true' do
        expect(discovery.send(:skip_device?, physical, true, true)).to be false
        expect(discovery.send(:skip_device?, physical, false, true)).to be false
      end

      it 'returns true if is_simulated is false' do
        expect(discovery.send(:skip_device?, physical, true, false)).to be true
        expect(discovery.send(:skip_device?, physical, false, false)).to be true
      end
    end

    context 'when reality is unknown (nil)' do
      let(:physical) { nil }

      it 'behaves like a simulated device' do
        expect(discovery.send(:skip_device?, physical, true, true)).to be false
        expect(discovery.send(:skip_device?, physical, true, false)).to be true
      end
    end
  end
end
