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
fn C.udev_device_get_sysattr_value(&C.udev_device, &char) &char
struct MonitorData{
	device string
	callback_connected ?fn ()
	callback_disconnected ?fn ()
}
fn enumerate_devices(udev &C.udev, data MonitorData) map[string]string {
	devices := map[string]string
	enumerate := C.udev_enumerate_new(udev)
	C.udev_enumerate_add_match_subsystem(enumerate, c'usb')
	C.udev_enumerate_scan_devices(enumerate)
	mut entry := C.udev_enumerate_get_list_entry(enumerate)
	for entry != 0 {
		path := C.udev_list_entry_get_name(entry)
		dev := C.udev_device_new_from_syspath(udev, path)
		unsafe {
			syspath := C.udev_device_get_syspath(dev).vstring()
			c_vendor := C.udev_device_get_sysattr_value(dev,c"idVendor")
			c_device := C.udev_device_get_sysattr_value(dev,c"idProduct")

			if c_vendor != nil && c_device != nil {
				println('Device Found: ${c_vendor.vstring()}:${c_device.vstring()}')
				if data.device == '${c_vendor.vstring()}:${c_device.vstring()}' {
					if callback_connected := data.callback_connected {
						callback_connected()
					}
				}
			}
			devices[syspath] = '${c_vendor.vstring()}:${c_device.vstring()}'
		}
		C.udev_device_unref(dev)
		entry = C.udev_list_entry_get_next(entry)
	}

	C.udev_enumerate_unref(enumerate)
	return devices
}

// Function to monitor USB devices
fn monitor_devices(udev &C.udev, devices  map[string]string, data MonitorData) {
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
					c_vendor := C.udev_device_get_sysattr_value(dev,c"idVendor")
					c_device := C.udev_device_get_sysattr_value(dev,c"idProduct")
								syspath := C.udev_device_get_syspath(dev).vstring()

					if c_vendor != nil && c_device != nil {
						if action == 'bind' {
							println('Added device: ${c_vendor.vstring()}:${c_device.vstring()}')
							if data.device == '${c_vendor.vstring()}:${c_device.vstring()}' {
								if callback_connected := data.callback_connected {
									callback_connected()
								}
							}
						} 
					}
					if action == 'unbind' && devices[syspath] != '' {
						println('Removed device: ${devices[syspath]}')
							if data.device == '${c_vendor.vstring()}:${c_device.vstring()}' {
								if callback_disconnected := data.callback_disconnected {
									callback_disconnected()
								}
							}
					}
				}
				C.udev_device_unref(dev)
			} else {
				println('No device received. An error occurred.')
			}
		}
	}
}



fn init(data MonitorData) {
	udev := C.udev_new()
	defer {
		C.udev_unref(udev)
	}
	// Enumerate existing USB devices
	devices := enumerate_devices(udev, data)

	// Monitor for new devices
	monitor_devices(udev, devices, data)

}