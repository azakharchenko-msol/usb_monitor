# USB Monitor Tool

This tool is designed to automatically run applications or scripts when a specified USB device is connected or disconnected. It is particularly useful for automating tasks or triggering events based on the connection status of specific USB devices.

**Note: This tool is for Linux systems only.**


## Building the Tool


To build the USB monitor tool, follow these steps:

1. Install the V programming language by following the instructions on the official website: https://vlang.io/
2. Install the `libusb-dev` package, which is required for USB support:
3. Navigate to the root directory of the project.
4. Run the following command to compile the project with global variables enabled:

```sh
v -enable-globals .
```

## Using the Tool

To use the USB monitor tool, follow these steps:

1. Run the compiled binary to generate a configuration example:

```sh
./usbmon
```

2. Exit the tool once the configuration example has been generated.
3. Go to the `~/.usbmon/` directory to adjust the configuration according to your needs.
4. Run the tool again to start monitoring the specified USB device.

## Configuration

The configuration file is located at `~/.usbmon/config.yaml`. Here is an example of what the configuration might look like:

```yaml
device: "1a86:7523" # Replace with your device's ID
on_add_script: "/home/user/.usbmon/on_device_added.sh" # Path to the script to run when the device is connected
on_remove_script: "/home/user/.usbmon/on_device_removed.sh" # Path to the script to run when the device is disconnected
```

Replace the `device` field with the ID of the USB device you want to monitor. Update the paths for `on_add_script` and `on_remove_script` to point to the scripts you wish to execute upon device connection and disconnection, respectively.

## License

This project is licensed under the terms of the MIT license. See the LICENSE file for details.
