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
end
