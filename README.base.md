<!---------------------------->
<!-- multilingual suffix: en, ja -->
<!-- no suffix: en -->
<!---------------------------->

<!-- $ mmg -y README.base.md -->

# mdq - Mobile Device Query

[![Gem Version](https://badge.fury.io/rb/mdq.svg)](https://badge.fury.io/rb/mdq)

MDQ stands for Mobile Device Query and is a command line tool for displaying information about Android and Apple devices.  

# Usage

## Check

To fully use MDQ, you need to install ADB and Xcode beforehand.
Check the software installation status.

```
$ mdq check
```

## List

It's easy to use.

```
$ mdq list
[
  {
    "id": 1,
    "udid": "ANDROID_UDID",
    "serial_number": "ANDROID_UDID",
    "name": "Pixel 7",
    "authorized": true,
    "platform": "Android",
    "marketing_name": null,
    "model": "Pixel 7",
    "build_version": "16",
    "build_id": "BP31.250502.008",
    "battery_level": 88,
    "total_disk": 118015217664,
    "used_disk": 19287748608,
    "available_disk": 98727469056,
    "capacity": 16,
    "human_readable_total_disk": "109.91 GB",
    "human_readable_used_disk": "17.96 GB",
    "human_readable_available_disk": "91.95 GB"
  },
  {
    "id": 2,
    "udid": "APPLE_UDID",
    "serial_number": "XXX",
    "name": "iPhone 16 Pro",
    "authorized": true,
    "platform": "iOS",
    "marketing_name": "iPhone 16 Pro",
    "model": "iPhone17,1",
    "build_version": "18.4.1",
    "build_id": "22E252",
    "battery_level": null,
    "total_disk": 128000000000,
    "used_disk": null,
    "available_disk": null,
    "capacity": null,
    "human_readable_total_disk": "128.0 GB",
    "human_readable_used_disk": null,
    "human_readable_available_disk": null
  }
]
```

You can filter using SQL.

```
$ mdq list -q="select * from devices where platform='iOS'"
[
  {
    "id": 1,
    "udid": "APPLE_UDID",
    "serial_number": "XXX",
    "name": "iPhone 16 Pro",
    "authorized": true,
    "platform": "iOS",
    "marketing_name": "iPhone 16 Pro",
    "model": "iPhone17,1",
    "build_version": "18.4.1",
    "build_id": "22E252",
    "battery_level": null,
    "total_disk": 128000000000,
    "used_disk": null,
    "available_disk": null,
    "capacity": null,
    "human_readable_total_disk": "128.0 GB",
    "human_readable_used_disk": null,
    "human_readable_available_disk": null
  }
]
```

View apps installed on your device.
Apple Devices displays the apps installed with Xcode.

```
$ mdq list -q='select * from apps'
```

Take a screenshot on Android.

```
$ mdq list --cap='/Users/xxxxx/'
```

Install the app.

```
$ mdq list --install='/Users/xxxxx/example.apk'
$ mdq list --install='/Users/xxxxx/example.ipa'
```

Uninstall the app.

```
$ mdq list --uninstall='com.example.app'
```



# Specification

Details of the devices table.

| name | android | apple devices |
| -- | -- | -- |
| udid | Serial number | hardwareProperties.udid |
| serial_number | Serial number | hardwareProperties.serialNumber |
| name | device_name | deviceProperties.name | 
| authorized | "False" if additional authentication is required. | Always "True" |
| platform | Always "Android" | hardwareProperties.platform |
| marketing_name | Always "null" | hardwareProperties.marketingName |
| model | ro.product.model | hardwareProperties.productType |
| build_version | ro.build.version.release | deviceProperties.osVersionNumber |
| build_id | ro.build.id | deviceProperties.osBuildUpdate | 
| battery_level | battery | Always "null" |
| total_disk | df | hardwareProperties.internalStorageCapacity |
| available_disk | df | Always "null" |
| used_disk | total_disk - total_disk | Always "null" |
| capacity | (used_disk / total_disk) * 100 | Always "null" |
| human_readable_total_disk | total_disk | total_disk |
| human_readable_available_disk | available_disk | Always "null" |
| human_readable_used_disk | used_disk | Always "null" |

Details of the apps table.
Apple Devices displays the apps installed with Xcode.

| name | android | apple devices |
| -- | -- | -- |
| udid | Serial number | hardwareProperties.udid |
| name | Always "null" | name |
| package_name | Package name | bundleIdentifier |
| version | Always "null" | version |