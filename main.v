
import os
import log
__global (
 config_folder =  string("${os.getenv("HOME")}/.usbmon")
 config_file  = string("${config_folder}/config.yaml")
)

fn get_config() Config{
	return Config.load(config_file) or {  
		log.error("no config found on path ${config_file}")
		exit(1)
		}
}
fn create_folders() !bool {
	if !os.exists(config_folder){
		log.info("create ${config_folder} folder")
		os.mkdir(config_folder) or {
			log.error("failed to create ${config_folder}/.usbmon folder")
		}
		add_script_path := "${config_folder}/on_device_added.sh"
		remove_script_path := "${config_folder}/on_device_removed.sh"

		mut add_script := os.open_file(add_script_path,"w", 0o777) or {
			log.error("failed to create ${add_script_path}")
			return false
		}
		add_script.write_string("#!/bin/bash\r\n") or {}
		add_script.close()
		mut remove_script := os.open_file(remove_script_path,"w", 0o777)  or {
			log.error("failed to create ${remove_script_path}")
			return false
		}
		remove_script.write_string("#!/bin/bash\r\n") or {}
		remove_script.close()
		mut config := os.open_file(config_file,"w") or {
			log.error("failed to create ${config_file}")
			return false
		}
		config.write_string("device: \"\"\r\n") or {}
		config.write_string("on_add_script: \"${add_script_path}\"\r\n") or {}
		config.write_string("on_remove_script: \"${remove_script_path}\"\r\n") or {}
		config.close()

	}
	return true
}
// Main function
fn main() {
	log.info("use monitoring started...")
	udev := C.udev_new()
	defer {
		C.udev_unref(udev)
	}
	create_folders() or {  }
	config := get_config()
	log.info("loaded config: ${config_file}")
	log.info("monitoring device: ${config.device}")


	mut data := MonitorData{
		device: config.device
		callback_connected: fn(){}
		callback_disconnected: fn(){}
	}
	if config.on_add_script != '' && os.exists(config.on_add_script) {
		data.callback_connected  = fn [config] () {  {os.execute(config.on_add_script)} }
	}
	if config.on_remove_script != '' && os.exists(config.on_remove_script) {
		data.callback_disconnected  = fn [config] () { {os.execute(config.on_remove_script)} }
	}
	init(data)
}
