#include "header.h"
#include <stdio.h>
#include <stdbool.h>
#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>

int data_available(int fd){
    fd_set fds;
    struct timeval tv;
    int ret;

    FD_ZERO(&fds);
    FD_SET(fd, &fds);
    tv.tv_sec =  1;
    tv.tv_usec =  0;

    ret = select(fd+1, &fds, NULL, NULL, &tv);
    if (ret >  0 && FD_ISSET(fd, &fds)) {
        return 1;
    }
    return 0;
}