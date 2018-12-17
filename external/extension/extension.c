#include <poll.h>

/* Polls on a file descriptor until the timeout is hit or a event has been received.
 * returning 0 on success, -1 on timeout and -2 on a poll error.
 */
int wpa_ctrl_poll(int fileDescriptor, int timeout) {
	struct pollfd descriptorStruct = {
		.fd = fileDescriptor,
		.events = POLLIN | POLLPRI
	};
	int resultCode = poll(&descriptorStruct, 1, timeout);
	return resultCode - 1;
}

