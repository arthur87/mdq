

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

Details of the devices table.

| name | description |
| -- | -- |
| serial_number | This is the serial number of the device. |
| name | User configurable name for the device. |
| authorized | False if Android requires additional authentication. Will always be true for Apple devices.　|
| platform |　The device platform. |
| marketing_name | For Apple devices, the marketing name is displayed. |
| model | The device model. |
| build_version | The OS version. |
| build_id | The detailed OS version. |
| battery_level | Displays the battery capacity. For Apple devices, this will always be null. |
| total_capacity | Displays the storage capacity. For Apple devices, this will always be null. |
| free_capacity | Displays the available storage space. For Apple devices, this will always be null. |