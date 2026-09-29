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

  describe '#android_battery' do
    it 'parses battery level from adb output' do
      output = 'level: 88'

      expect(discovery.send(:android_battery, output)).to eq 88
    end
  end

  describe '#android_disk' do
    it 'parses disk information from adb output' do
      expect(discovery.send(:android_disk,
                            File.read("#{__dir__}/android-df.txt"))).to eq [118_015_217_664.0, 19_287_748_608.0,
                                                                            98_727_469_056.0, 16.34344196433545]
    end
  end

  describe '#android_address' do
    it 'parses MAC and IP addresses from adb output' do
      expect(discovery.send(:android_address,
                            File.read("#{__dir__}/android-ip.txt"))).to eq ['ff:ff:ff:ff:ff:ff', '192.168.1.1',
                                                                            'IPV6_1,IPV6_2,IPV6_3,IPV6_3']
    end
  end

  describe '#android_wifi_network' do
    it 'parses Wi-Fi network from wifiNetworkKey' do
      expect(discovery.send(:android_wifi_network,
                            File.read("#{__dir__}/android-wifi-network-key.txt"))).to eq 'MyNet'
    end

    it 'parses Wi-Fi network from networkId' do
      expect(discovery.send(:android_wifi_network,
                            File.read("#{__dir__}/android-network-id.txt"))).to eq 'MyNet'
    end

    it 'returns nil if no Wi-Fi network is found' do
      output = 'iface=wlan0 ident=[{type=1, ratType=COMBINED, metered=false, defaultNetwork=true, oemManaged=OEM_NONE, subId=-1}]'
      expect(discovery.send(:android_wifi_network, output)).to be_nil
    end
  end
end
