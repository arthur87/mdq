# frozen_string_literal: true

require 'mdq'
require 'mdq/db'

RSpec.describe Mdq::DB do # rubocop:disable Metrics/BlockLength
  let(:db) { Mdq::DB.new }
  let(:file) do
    [Dir.home, '.mdq', 'mdq.json'].join(File::Separator)
  end
  let(:apps_file) do
    [Dir.home, '.mdq', 'mdq-apps.json'].join(File::Separator)
  end

  before do
    FileUtils.mkdir_p([Dir.home, '.mdq'].join(File::Separator))
    allow(db).to receive(:sell).and_call_original

    # Android Devices
    allow(db).to receive(:adb_command).with('devices -l').and_return(File.read("#{__dir__}/android-devices.txt"))

    allow(db).to receive(:adb_command).with('shell getprop ro.product.model',
                                            'ANDROID_UDID').and_return('Pixel 7')
    allow(db).to receive(:adb_command).with('shell getprop ro.build.version.release',
                                            'ANDROID_UDID').and_return('16')
    allow(db).to receive(:adb_command).with('shell getprop ro.build.id',
                                            'ANDROID_UDID').and_return('BP31.250502.008')
    allow(db).to receive(:adb_command).with('shell settings get global device_name',
                                            'ANDROID_UDID').and_return('Pixel 7')
    allow(db).to receive(:adb_command).with('shell dumpsys battery', 'ANDROID_UDID').and_return('level: 88')
    allow(db).to receive(:adb_command).with('shell df',
                                            'ANDROID_UDID').and_return(File.read("#{__dir__}/android-df.txt"))

    allow(db).to receive(:adb_command).with('version').and_return(File.read("#{__dir__}/adb-version.txt"))

    allow(db).to receive(:adb_command).with('shell pm list packages',
                                            'ANDROID_UDID').and_return(File.read("#{__dir__}/android-packages.txt"))

    allow(db).to receive(:adb_command).with('shell ip addr show wlan0',
                                            'ANDROID_UDID').and_return(File.read("#{__dir__}/android-ip.txt"))

    allow(db).to receive(:adb_command).with("shell dumpsys netstats | grep -E 'iface=wlan0'",
                                            'ANDROID_UDID').and_return(File.read("#{__dir__}/android-wifi-network-key.txt"))

    # Apple Devices
    allow(db).to receive(:apple_command).with("list devices -v -j #{file}").and_return(nil)
    allow(db).to receive(:apple_command).with('--version').and_return(443.19)
    allow(db).to receive(:apple_command).with("device info apps -j #{apps_file}",
                                              'APPLE_UDID').and_return(nil)
  end

  it 'check' do
    expect(db.send(:android_discoverable?)).to be true
    expect(db.send(:apple_discoverable?)).to be true
  end

  it 'db' do
    FileUtils.cp([__dir__, 'mdq.json'].join(File::Separator), file)

    db.send(:android_discover)
    db.send(:apple_discover)

    devices = Device.all
    test_devices = [{
      "id": 1,
      "udid": 'ANDROID_UDID',
      "serial_number": 'ANDROID_UDID',
      "name": 'Pixel 7',
      "authorized": true,
      "platform": 'Android',
      "marketing_name": nil,
      "model": 'Pixel 7',
      "physical": true,
      "build_version": '16',
      "build_id": 'BP31.250502.008',
      "battery_level": nil,
      "total_disk": nil,
      "used_disk": nil,
      "available_disk": nil,
      "capacity": nil,
      "human_readable_total_disk": nil,
      "human_readable_used_disk": nil,
      "human_readable_available_disk": nil,
      "mac_address": nil,
      "ip_address": nil,
      "ipv6_address": nil,
      "wifi_network": nil
    }, {
      "id": 2,
      "udid": 'APPLE_UDID',
      "serial_number": 'XXX',
      "name": 'iPhone 16 Pro',
      "authorized": true,
      "platform": 'iOS',
      "marketing_name": 'iPhone 16 Pro',
      "model": 'iPhone17,1',
      "physical": true,
      "build_version": '18.4.1',
      "build_id": '22E252',
      "battery_level": nil,
      "total_disk": 128_000_000_000,
      "used_disk": nil,
      "available_disk": nil,
      "capacity": nil,
      "human_readable_total_disk": '128.0 GB',
      "human_readable_used_disk": nil,
      "human_readable_available_disk": nil,
      "mac_address": nil,
      "ip_address": nil,
      "ipv6_address": nil,
      "wifi_network": nil
    }].to_json

    expect(devices.to_json).to eq test_devices
  end

  it 'apps' do
    FileUtils.cp([__dir__, 'mdq.json'].join(File::Separator), file)
    FileUtils.cp([__dir__, 'mdq-apps.json'].join(File::Separator), apps_file)

    db.send(:get, is_apps: true)
    apps = App.all
    test_apps = [
      { "id": 1, "udid": 'ANDROID_UDID', "name": nil, "package_name": 'com.example.android1', "version": nil },
      { "id": 2, "udid": 'ANDROID_UDID', "name": nil, "package_name": 'com.example.android2',
        "version": nil },
      { "id": 3, "udid": 'APPLE_UDID', "name": 'App', "package_name": 'com.example.apple',
        "version": '5.4' }
    ].to_json

    expect(apps.to_json).to eq test_apps
  end

  it 'query_contains_apps_table?' do
    expect(db.send(:query_contains_apps_table?, 'SELECT * FROM apps')).to be true
    expect(db.send(:query_contains_apps_table?,
                   'SELECT * FROM devices INNER JOIN apps ON devices.udid = apps.udid')).to be true
    expect(db.send(:query_contains_apps_table?, 'SELECT * FROM devices')).to be false
    expect(db.send(:query_contains_apps_table?, 'SELECT * FROM')).to be false
  end
end
