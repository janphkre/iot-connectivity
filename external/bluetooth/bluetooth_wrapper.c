//Requires: sudo apt-get install libbluetooth-dev libdbus-1-dev

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <bluetooth/rfcomm.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define BUF_SIZE 16384
#define LISTEN_QUEUE_SIZE 4

typedef struct {
    int readingSocket;
    int writingSocket;
} SocketInfo;

int startBluetoothServerSocket(int bluetoothPort, bdaddr_t bdaddr);
int acceptBluetoothSocket(int serverSocket);
void hookBluetoothSocket(int bluetoothSocket, int targetPort);
void* hookSockets(void* data);
int startLocalClientSocket(int targetPort);
int pipeData(int sourceSocket, int targetSocket, char* buffer);

int main(int argc, char **argv) {
    int serverPort, bluetoothPort, bluetoothDevice;

    if(argc != 4) {
        printf("Usage:\nWrappes a server in a bluetooth connection.\nFirst argument is the server port,\nSecond is the desired bluetooth port,\nThird is the bluetooth device id\n");
        return -1;
    }
    if (sscanf (argv[1], "%i", &serverPort) != 1) {
        printf("ERR: Server port is not an integer!\n");
        return -2;
    }
    if (sscanf (argv[2], "%i", &bluetoothPort) != 1) {
        printf("ERR: Bluetooth port is not an integer!\n");
        return -3;
    }
    if (sscanf (argv[3], "%i", &bluetoothDevice) != 1) {
        printf("ERR: Bluetooth device id is not an integer!\n");
        return -4;
    }

    bdaddr_t bdaddr = { 0 };
    if(hci_devba(bluetoothDevice, &bdaddr) < 0) {
        printf("ERR: No device found for the given device id %i.\n", bluetoothDevice);
        return -10;
    }
    int bluetoothSocket = startBluetoothServerSocket(bluetoothPort, bdaddr);
    if (bluetoothSocket < 0) {
        return -11;
    }

//TODO:
    /*if(startDbusDiscovery() < 0) {
       printf("ERR: Failed start discovery!\n");
        close(bluetoothSocket);
        return -14;
    }*/

    while(1) {
        int client = acceptBluetoothSocket(bluetoothSocket);
	if(client < 0) {
            printf("ERR: Accept failed\n");
            continue;
        }
        hookBluetoothSocket(client, serverPort);
    }

    close(bluetoothSocket);
    printf("\n");
    return 0;
}

//Mostly taken from : https://people.csail.mit.edu/albert/bluez-intro/x502.html#rfcomm-server.c
int startBluetoothServerSocket(int bluetoothPort, bdaddr_t bdaddr) {
    struct sockaddr_rc loc_addr = { 0 };
    int s;

    // allocate socket
    s = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
    if (s == -1) {
        printf("ERR: Could not create bluetooth socket.\n");
        return -1;
    }

    // bind socket to the specified port of the first available 
    // local bluetooth adapter
    loc_addr.rc_family = AF_BLUETOOTH;
    loc_addr.rc_bdaddr = *BDADDR_ANY;
    loc_addr.rc_channel = (uint8_t) bluetoothPort;
    bind(s, (struct sockaddr *)&loc_addr, sizeof(loc_addr));

    // put socket into listening mode
    if(listen(s, LISTEN_QUEUE_SIZE) < 0) {
        printf("ERR: Failed to listen on bluetooth socket.\n");
        close(s);
        return -2;
    }

    return s;
}

int acceptBluetoothSocket(int serverSocket) {
    struct sockaddr_rc rem_addr = { 0 };
    socklen_t opt = sizeof(rem_addr);

    // accept one connection
    printf("Accepting a connection.\n");
    return accept(serverSocket, (struct sockaddr *)&rem_addr, &opt);
}

void hookBluetoothSocket(int bluetoothSocket, int targetPort) {
    printf("Hooking bluetooth up");
    int targetSocket = startLocalClientSocket(targetPort);
    if(targetSocket < 0) {
        goto free_stuff;
    }
    printf(" to socket %d.\n", targetSocket);
    pthread_t readThread;
    SocketInfo* targetRead = malloc(sizeof(SocketInfo));
    targetRead -> readingSocket = targetSocket;
    targetRead -> writingSocket = bluetoothSocket;
    if(pthread_create(&readThread, NULL, hookSockets, targetRead) != 0) {
        printf("ERR: Failed to start the target read thread.\n");
        goto free_stuff;
    }

    pthread_t writeThread;
    SocketInfo* targetWrite = malloc(sizeof(SocketInfo));
    targetWrite -> readingSocket = bluetoothSocket;
    targetWrite -> writingSocket = targetSocket;
    if(pthread_create(&writeThread, NULL, hookSockets, targetWrite) != 0) {
        printf("ERR: Failed to start the target write thread.\n");
        goto free_stuff;
    }

    pthread_join(readThread, NULL);
    pthread_cancel(writeThread);
    pthread_join(writeThread, NULL);
free_stuff:
    free(targetRead);
    free(targetWrite);
    close(bluetoothSocket);
    close(targetSocket);
}

void* hookSockets(void* data) {
    SocketInfo sockets = *((SocketInfo*) data);
    char buffer[BUF_SIZE] = { 0 };
    while(pipeData(sockets.readingSocket, sockets.writingSocket, buffer) >= 0) { ;; }
    return NULL;
}

int startLocalClientSocket(int targetPort) {
    int s;
    struct sockaddr_in rem_addr = { 0 };

    //Create socket
    s = socket(AF_INET, SOCK_STREAM , 0);
    if (s == -1) {
        printf("\nERR: Could not create local socket.\n");
        return -1;
    }

    //Connect to local server
    rem_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    rem_addr.sin_family = AF_INET;
    rem_addr.sin_port = htons(targetPort);

    if (connect(s, (struct sockaddr *)&rem_addr , sizeof(rem_addr)) < 0) {
        printf("\nERR: Connect failed.\n");
        close(s);
        return -2;
    }
    return s;
}

int pipeData(int sourceSocket, int targetSocket, char* buffer) {
    int bytes_read, bytes_sent;

    bytes_read = read(sourceSocket, buffer, BUF_SIZE);
    if(bytes_read < 0) {
        printf("ERR: recv failed.\n");
        return -1;
    }
    if(bytes_read == 0) {
        // CLOSE SOCKETS (EOF)
        return -20;
    }

    printf("%s\n", buffer);

    bytes_sent = send(targetSocket, buffer, bytes_read, 0);
    if(bytes_sent < 0) {
        printf("ERR: send failed\n");
        return -2;
    }

    if(bytes_read != bytes_sent) {
        printf("ERR: Read %d bytes but sent %d bytes.\n", bytes_read, bytes_sent);
        //TODO: THIS MAY INDICATE A FAILURE
    }
    memset(buffer, 0, BUF_SIZE);
    return 0;
}
