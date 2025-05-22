# frozen_string_literal: true

require 'mdq'
require 'mdq/db'

RSpec.describe Mdq::DB do
  let(:db) { Mdq::DB.new }
  let(:android_device) do
    ['List of devices attached',
     'ANDROID_UDID         device 2-1 product:panther_beta model:Pixel_7 device:panther transport_id:10']
      .join("\n")
  end
  let(:file) do
    [Dir.home, '.mdq'].join(File::Separator)
  end

  before do
    allow(db).to receive(:sell).and_call_original
    allow(db).to receive(:adb_command).with('devices -l').and_return(android_device)

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

    allow(db).to receive(:apple_command).with("list devices -v -j #{file}").and_return(nil)
  end

  it 'devices' do
    expect(db.send(:adb_command, 'devices -l')).to eq android_device
    expect(db.send(:apple_command, "list devices -v -j #{file}")).to eq nil

    FileUtils.cp([__dir__, 'mdq.json'].join(File::Separator), file)

    db.send(:android_discover)
    db.send(:apple_discover)

    devices = Device.all
    test_devices = [{
      id: 1,
      udid: 'ANDROID_UDID',
      serial_number: 'ANDROID_UDID',
      name: 'Pixel 7',
      authorized: true,
      platform: 'Android',
      marketing_name: nil,
      model: 'Pixel 7',
      build_version: '16',
      build_id: 'BP31.250502.008',
      battery_level: 88,
      total_capacity: 115_249_236,
      free_capacity: 96_413_544
    }, {
      id: 2,
      udid: 'APPLE_UDID',
      serial_number: 'XXX',
      name: 'iPhone 16 Pro',
      authorized: true,
      platform: 'iOS',
      marketing_name: 'iPhone 16 Pro',
      model: 'iPhone17,1',
      build_version: '18.4.1',
      build_id: '22E252',
      battery_level: nil,
      total_capacity: 128_000_000_000,
      free_capacity: nil
    }].to_json

    expect(devices.to_json).to eq test_devices
  end
end
