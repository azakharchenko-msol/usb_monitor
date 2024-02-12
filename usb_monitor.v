import os
import vselect

#flag -I/usr/include -L/usr/lib

#flag -ludev
#include <libudev.h>
#include <sys/select.h>
// Define the necessary C types and functions in V
pub struct C.udev {}

pub struct C.udev_monitor {}

pub struct C.udev_device {}

pub struct C.udev_enumerate {}

pub struct C.udev_list_entry {}

fn C.udev_new() &C.udev
fn C.udev_unref(&C.udev)
fn C.udev_monitor_new_from_netlink(&C.udev, &char) &C.udev_monitor
fn C.udev_monitor_filter_add_match_subsystem_devtype(&C.udev_monitor, &char, &char)
fn C.udev_monitor_enable_receiving(&C.udev_monitor)
fn C.udev_monitor_get_fd(&C.udev_monitor) int
fn C.udev_monitor_receive_device(&C.udev_monitor) &C.udev_device
fn C.udev_device_get_action(&C.udev_device) &char
fn C.udev_device_get_devnode(&C.udev_device) &char
fn C.udev_device_get_subsystem(&C.udev_device) &char
fn C.udev_device_get_devtype(&C.udev_device) &char
fn C.udev_device_unref(&C.udev_device)
fn C.udev_enumerate_new(&C.udev) &C.udev_enumerate
fn C.udev_enumerate_add_match_subsystem(&C.udev_enumerate, &char)
fn C.udev_enumerate_scan_devices(&C.udev_enumerate)
fn C.udev_enumerate_get_list_entry(&C.udev_enumerate) &C.udev_list_entry
fn C.udev_list_entry_foreach(&C.udev_list_entry, &C.udev_list_entry)
fn C.udev_list_entry_get_name(&C.udev_list_entry) &char
fn C.udev_device_new_from_syspath(&C.udev, &char) &C.udev_device
fn C.udev_device_get_syspath(&C.udev_device) &char
fn C.udev_enumerate_unref(&C.udev_enumerate)
fn C.ioctl(fd int, request u64, arg voidptr) int
fn C.udev_list_entry_get_next(&C.udev_list_entry) &C.udev_list_entry

fn enumerate_devices(udev &C.udev) {
	enumerate := C.udev_enumerate_new(udev)
	C.udev_enumerate_add_match_subsystem(enumerate, c'usb')
	C.udev_enumerate_scan_devices(enumerate)
	mut entry := C.udev_enumerate_get_list_entry(enumerate)
	for entry != 0 {
		path := C.udev_list_entry_get_name(entry)
		dev := C.udev_device_new_from_syspath(udev, path)
		unsafe {
			syspath := C.udev_device_get_syspath(dev).vstring()
			println('Device Found: ${syspath}')
		}
		C.udev_device_unref(dev)
		entry = C.udev_list_entry_get_next(entry)
	}

	C.udev_enumerate_unref(enumerate)
}

// Function to monitor USB devices
fn monitor_devices(udev &C.udev) {
	mon := C.udev_monitor_new_from_netlink(udev, c'udev')
	C.udev_monitor_filter_add_match_subsystem_devtype(mon, c'usb', c'usb_device')
	C.udev_monitor_enable_receiving(mon)
	fd := C.udev_monitor_get_fd(mon)

	for {
		ret := vselect.data_available(fd)
		if ret > 0 {
			dev := C.udev_monitor_receive_device(mon)
			if dev != 0 {
				unsafe {
					action := C.udev_device_get_action(dev).vstring()
					devnode := C.udev_device_get_devnode(dev).vstring()
					subsystem := C.udev_device_get_subsystem(dev).vstring()
					devtype := C.udev_device_get_devtype(dev).vstring()

					println('Device ${action}: ${devnode} (subsystem: ${subsystem}, devtype: ${devtype})')
				}
				C.udev_device_unref(dev)
			} else {
				println('No device received. An error occurred.')
			}
		}
	}
}

// Main function
fn main() {
	udev := C.udev_new()
	defer {
		C.udev_unref(udev)
	}
	// Enumerate existing USB devices
	enumerate_devices(udev)

	// Monitor for new devices
	monitor_devices(udev)
}
