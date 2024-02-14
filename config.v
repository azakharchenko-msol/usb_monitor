import prantlf.yaml
import os 
import log

struct Config {
	device string
	on_add_script string
	on_remove_script string

}
fn Config.load(filename string) ?Config {
	
	return yaml.unmarshal_file[Config](filename) or { 
		log.error("Error unmarshalling config file: ${filename}")
		return none
	 }
}
