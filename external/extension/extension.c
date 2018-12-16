#include <poll.h>

int wpa_ctrl_poll(int fileDescriptor, short requestedEvents, short *returnedEvents, int timeout) {
	struct pollfd descriptorStruct = { .fd = fileDescriptor, .events = requestedEvents };
	int resultCode = poll(&descriptorStruct, 1, timeout);
	*returnedEvents = descriptorStruct.revents;
	return resultCode;
}

