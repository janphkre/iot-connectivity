#include <stddef.h>
#include <poll.h>
#include "../hostap/src/common/wpa_ctrl.h"

/* 
 * Polls on the given control until the timeout is hit or a event has been received.
 * returning 1 if there are pending events, 0 on timeout, -1 on a error.
 */
int wpa_ctrl_poll(struct wpa_ctrl * control, int timeout) {
	int fileDescriptor = wpa_ctrl_get_fd(control);
	if(fileDescriptor <= 0) {
		return -1;
	}
	struct pollfd descriptorStruct = {
		.fd = fileDescriptor,
		.events = POLLIN | POLLPRI
	};
	return poll(&descriptorStruct, 1, timeout);
}

