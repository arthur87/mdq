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
    allow(db).to receive(:adb_command).with('devices -l').and_return(
      ['List of devices attached',
       'ANDROID_UDID         device 2-1 product:panther_beta model:Pixel_7 device:panther transport_id:10']
         .join("\n")
    )

    allow(db).to receive(:adb_command).with('shell getprop ro.product.model',
                                            'ANDROID_UDID').and_return('Pixel 7')
    allow(db).to receive(:adb_command).with('shell getprop ro.build.version.release',
                                            'ANDROID_UDID').and_return('16')
    allow(db).to receive(:adb_command).with('shell getprop ro.build.id',
                                            'ANDROID_UDID').and_return('BP31.250502.008')
    allow(db).to receive(:adb_command).with('shell settings get global device_name',
                                            'ANDROID_UDID').and_return('Pixel 7')
    allow(db).to receive(:adb_command).with('shell dumpsys battery', 'ANDROID_UDID').and_return('level: 88')
    allow(db).to receive(:adb_command).with('shell df', 'ANDROID_UDID').and_return(
      ['tmpfs               3814068        0   3814068   0% /tmp',
       '/dev/block/dm-74  115249236 18704620  96413544  17% /data'].join("\n")
    )

    allow(db).to receive(:adb_command).with('version').and_return(
      ['Android Debug Bridge version 1.0.41',
       'Version 35.0.1-11580240',
       'Installed as /opt/homebrew/bin/adb',
       'Running on Darwin 24.4.0 (arm64)'].join('\n')
    )

    allow(db).to receive(:adb_command).with('shell pm list packages', 'ANDROID_UDID').and_return(
      ['package:com.example.android1', 'package:com.example.android2'].join("\n")
    )

    # Apple Devices
    allow(db).to receive(:apple_command).with("list devices -v -j #{file}").and_return(nil)
    allow(db).to receive(:apple_command).with('--version').and_return(443.19)
    allow(db).to receive(:apple_command).with("device info apps -j #{apps_file}", 'APPLE_UDID').and_return(
      nil
    )
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
      "build_version": '16',
      "build_id": 'BP31.250502.008',
      "battery_level": 88,
      "total_disk": 115_249_236_000,
      "used_disk": 18_835_692_000,
      "available_disk": 96_413_544_000,
      "capacity": 16,
      "human_readable_total_disk": '115.25 GB',
      "human_readable_used_disk": '18.84 GB',
      "human_readable_available_disk": '96.41 GB'
    }, {
      "id": 2,
      "udid": 'APPLE_UDID',
      "serial_number": 'XXX',
      "name": 'iPhone 16 Pro',
      "authorized": true,
      "platform": 'iOS',
      "marketing_name": 'iPhone 16 Pro',
      "model": 'iPhone17,1',
      "build_version": '18.4.1',
      "build_id": '22E252',
      "battery_level": nil,
      "total_disk": 128_000_000_000,
      "used_disk": nil,
      "available_disk": nil,
      "capacity": nil,
      "human_readable_total_disk": '128.0 GB',
      "human_readable_used_disk": nil,
      "human_readable_available_disk": nil
    }].to_json

    expect(devices.to_json).to eq test_devices
  end

  it 'apps' do
    FileUtils.cp([__dir__, 'mdq.json'].join(File::Separator), file)
    FileUtils.cp([__dir__, 'mdq-apps.json'].join(File::Separator), apps_file)

    db.send(:get, 'select * from apps')
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
end
