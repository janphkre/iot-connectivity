#include "sq.h"
#include "SocketPlugin.h"

#include <sys/socket.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/rfcomm.h>

//Requires: sudo apt-get install libbluetooth-dev

#define PSP(S)		((privateSocketStruct *)((S)->privateSocketPtr))
#define SOCKET(S)		(PSP(S)->s)

extern privateSocketStruct;

static int thisNetSession = 0;

void lib_bluez_init() {
  thisNetSession = clock() + time(0);
}

// Adapted from https://github.com/OpenSmalltalk/opensmalltalk-vm/blob/0e962c5f37f639bee6c313bcc630a8cc5902273e/platforms/unix/plugins/SocketPlugin/sqUnixSocket.c
// (sqSocketCreateNetTypeSocketTypeRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID)
void lib_bluez_create_socket(SocketPtr s, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex) {
  int newSocket= -1;
  privateSocketStruct* pss = NULL;
  
  s->sessionID= 0;
  newSocket = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
  if (-1 == newSocket) {
    /* socket() failed */
    success(false);
    return;
  }
  setsockopt(newSocket, SOL_SOCKET, SO_REUSEADDR, (char *)&one, sizeof(one));
  /* private socket structure */
  pss= (privateSocketStruct *)calloc(1, sizeof(privateSocketStruct));
  if (pss == NULL) {
      fprintf(stderr, "bluetoothCreate: out of memory\n");
      success(false);
      return;
  }
  pss->s= newSocket;
  pss->connSema= semaIndex;
  pss->readSema= readSemaIndex;
  pss->writeSema= writeSemaIndex;

  pss->sockState= Unconnected;
  pss->sockError= 0;
  memset(&pss->peer, 0, sizeof(pss->peer));
  pss->peer.sin.sin_family= AF_BLUETOOTH;
  pss->peer.sin.sin_port= 0;
  pss->peer.sin.sin_addr.s_addr= BDADDR_ANY;//TODO what is the correct addr for the internal pointer?
  /* Squeak socket */
  s->sessionID= thisNetSession;//TODO: WHERE DOES thisNetSession come from?
  s->socketType= TCPSocketType;
  s->privateSocketPtr= pss;
  fprintf((stderr, "create(%d) -> %lx\n", SOCKET(s), (unsigned long)PSP(s)));
  /* Note: socket is in BLOCKING mode until aioEnable is called for it! */
}

void lib_bluez_bind_socket(SocketPtr s, int port) {
  struct sockaddr_rc loc_addr = { 0 };
  privateSocketStruct *pss= PSP(s);

  if (!socketValid(s)) return;

  // bind socket to a port of the first available 
  // local bluetooth adapter
  loc_addr.rc_family = AF_BLUETOOTH;
  loc_addr.rc_bdaddr = *BDADDR_ANY;
  loc_addr.rc_channel = (uint8_t) port;

  if (bind(SOCKET(s), (struct sockaddr *)&loc_addr, sizeof(loc_addr)) < 0) {
    pss->sockError= errno;
    success(false);
    return;
  }
}
