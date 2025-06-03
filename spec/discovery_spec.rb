# frozen_string_literal: true

require 'mdq'
require 'mdq/discovery'

RSpec.describe Mdq::Discovery do
  let(:discovery) { Mdq::Discovery.new }

  it 'discovery' do
    expect(discovery.send(:number_to_human_size, 1)).to eq '1.0 B'
    expect(discovery.send(:number_to_human_size, 1000)).to eq '1000.0 B'
    expect(discovery.send(:number_to_human_size, 1001)).to eq '1.0 KB'
    expect(discovery.send(:number_to_human_size, 123_456_789)).to eq '123.46 MB'
    expect(discovery.send(:number_to_human_size, 128_000_000_000)).to eq '128.0 GB'
  end
end
