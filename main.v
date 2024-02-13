
// Main function
fn main() {
	udev := C.udev_new()
	defer {
		C.udev_unref(udev)
	}
	data := MonitorData{
		device: '1d6b:0003'
		callback_connected: fn () {}
		callback_disconnected: fn () {}
	}

	init(data)
}
