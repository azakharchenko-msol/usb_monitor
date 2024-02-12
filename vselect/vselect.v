module vselect

#flag -I @VMODROOT/c
#flag @VMODROOT/c/implementation.o

#include "header.h"

fn C.data_available(int) int
pub fn data_available(fd int) int {
	return C.data_available(fd)
}