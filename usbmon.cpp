#include <iostream>
#include <libudev.h>
#include <locale.h>
#include <unistd.h>

static void enumerate_devices(struct udev* udev) {
    struct udev_enumerate* enumerate;
    struct udev_list_entry* devices, *dev_list_entry;
    struct udev_device* dev;

    // Create a list of the devices in the 'usb' subsystem.
    enumerate = udev_enumerate_new(udev);
    udev_enumerate_add_match_subsystem(enumerate, "usb");
    udev_enumerate_scan_devices(enumerate);
    devices = udev_enumerate_get_list_entry(enumerate);

    udev_list_entry_foreach(dev_list_entry, devices) {
        const char* path;
        path = udev_list_entry_get_name(dev_list_entry);
        dev = udev_device_new_from_syspath(udev, path);
        std::cout << "Device Found: " << udev_device_get_syspath(dev) << std::endl;
        udev_device_unref(dev);
    }

    // Free the enumerator object.
    udev_enumerate_unref(enumerate);
}

static void monitor_devices(struct udev* udev) {
    struct udev_monitor* mon;
    int fd;

    // Create the udev monitor.
    mon = udev_monitor_new_from_netlink(udev, "udev");
    udev_monitor_filter_add_match_subsystem_devtype(mon, "usb", "usb_device");
    udev_monitor_enable_receiving(mon);
    fd = udev_monitor_get_fd(mon);

    while (true) {
        fd_set fds;
        struct timeval tv;
        int ret;

        FD_ZERO(&fds);
        FD_SET(fd, &fds);
        tv.tv_sec = 0;
        tv.tv_usec = 0;

        ret = select(fd+1, &fds, nullptr, nullptr, &tv);

        // Check if our file descriptor has received data.
        if (ret > 0 && FD_ISSET(fd, &fds)) {
            struct udev_device* dev = udev_monitor_receive_device(mon);
            if (dev) {
                std::cout << "Device " << (udev_device_get_action(dev) ?: "exists") <<
                            ": " << udev_device_get_devnode(dev) <<
                            " (subsystem: " << udev_device_get_subsystem(dev) <<
                            ", devtype: " << udev_device_get_devtype(dev) << ")" << std::endl;
                udev_device_unref(dev);
            } else {
                std::cout << "No Device from receive_device(). An error occurred." << std::endl;
            }
        }
    }
}

int main() {
    struct udev* udev;

    // Create the udev object.
    udev = udev_new();
    if (!udev) {
        std::cerr << "Can't create udev\n";
        return 1;
    }

    // Enumerate existing USB devices.
    enumerate_devices(udev);
    // Start monitoring for new devices.
    monitor_devices(udev);

    udev_unref(udev);
    return 0;
}
