

# mdq - Mobile Device Query

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
    "udid": "XXXXX",
    "serial_number": "XXXXX",
    "name": "Pixel Tablet",
    "authorized": true,
    "platform": "Android",
    "marketing_name": null,
    "model": "Pixel Tablet",
    "build_version": "16",
    "build_id": "BP22.250325.012",
    "battery_level": 89,
    "total_capacity": 115855444,
    "free_capacity": 101137652
   },
   {
    "id": 2,
    "udid": "XXXXX",
    "serial_number": "XXXXX",
    "name": "iPhone 16 Pro",
    "authorized": true,
    "platform": "iOS",
    "marketing_name": "iPhone 16 Pro",
    "model": "iPhone17,1",
    "build_version": "18.4.1",
    "build_id": "22E252",
    "battery_level": null,
    "total_capacity": null,
    "free_capacity": null
  }
]
```

You can filter using SQL.

```
$ mdq list -q="select * from devices where platform='iOS'"
[
   {
    "id": 1,
    "udid": "XXXXX",
    "serial_number": "XXXXX",
    "name": "iPhone 16 Pro",
    "authorized": true,
    "platform": "iOS",
    "marketing_name": "iPhone 16 Pro",
    "model": "iPhone17,1",
    "build_version": "18.4.1",
    "build_id": "22E252",
    "battery_level": null,
    "total_capacity": null,
    "free_capacity": null
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
| total_capacity | df | Always "null" |
| free_capacity | df | Always "null" |


Details of the apps table.
Apple Devices displays the apps installed with Xcode.

| name | android | apple devices |
| -- | -- | -- |
| udid | Serial number | hardwareProperties.udid |
| name | Always "null" | name |
| package_name | Package name | bundleIdentifier |
| version | Always "null" | version |