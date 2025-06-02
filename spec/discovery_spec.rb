# frozen_string_literal: true

require 'mdq'
require 'mdq/discovery'

RSpec.describe Mdq::Discovery do
  let(:discovery) { Mdq::Discovery.new }

  it 'discovery' do
    expect(discovery.send(:number_to_human_size, 128_000_000_000)).to eq '128.0 GB'
  end
end
