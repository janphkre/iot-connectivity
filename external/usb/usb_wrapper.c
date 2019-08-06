#include <arpa/inet.h>
#include <poll.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define BUF_SIZE 16384
#define LISTEN_QUEUE_SIZE 4

typedef struct {
    int readingSocket;
    int writingSocket;
} SocketInfo;

int startUsbServerSocket(int usbPort);
int acceptUsbSocket(int serverSocket);
void hookUsbSocket(int usbSocket, int targetPort);
void* hookSockets(void* data);
int startLocalClientSocket(int targetPort);
int pipeData(int sourceSocket, int targetSocket, char* buffer);

int main(int argc, char **argv) {
    int serverPort, usbPort;

    if(argc != 3) {
        printf("Usage:\nWrappes a server in a usb connection.\nFirst argument is the server port,\nSecond is the local port for the usb server\n");
        return -1;
    }
    if (sscanf (argv[1], "%i", &serverPort) != 1) {
        printf("ERR: Server port is not an integer!\n");
        return -2;
    }
    if (sscanf (argv[2], "%i", &usbPort) != 1) {
        printf("ERR: Usb port is not an integer!\n");
        return -3;
    }

    int usbSocket = startUsbServerSocket(usbPort);
    if (usbSocket < 0) {
        return -11;
    }

    while(1) {
        int client = acceptUsbSocket(usbSocket);
	    if(client < 0) {
            printf("ERR: Accept failed\n");
            continue;
        }

        // waiting for data because the usbSocket is kept open
        printf("Waiting for data.\n");
        struct pollfd polling = { 0 };
        polling.fd = client;
        polling.events = POLLIN;
        poll(&polling, 1, -1);
        hookUsbSocket(client, serverPort);
    }

    close(usbSocket);
    printf("\n");
    return 0;
}

int startUsbServerSocket(int usbPort) {
    struct sockaddr_in loc_addr = { 0 };
    int s;

    // allocate socket
    s = socket(AF_INET, SOCK_STREAM, 0);
    if (s == -1) {
        printf("ERR: Could not create usb server socket.\n");
        return -1;
    }

    // bind socket to the specified port
    loc_addr.sin_family = AF_INET;
    loc_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    loc_addr.sin_port = htons(usbPort);
    bind(s, (struct sockaddr *)&loc_addr, sizeof(loc_addr));

    // put socket into listening mode
    if(listen(s, LISTEN_QUEUE_SIZE) < 0) {
        printf("ERR: Failed to listen on usb server socket.\n");
        close(s);
        return -2;
    }

    return s;
}

int acceptUsbSocket(int serverSocket) {
    struct sockaddr_in rem_addr = { 0 };
    socklen_t opt = sizeof(rem_addr);

    // accept one connection
    printf("Accepting a connection.\n");
    return accept(serverSocket, (struct sockaddr *)&rem_addr, &opt);
}

void hookUsbSocket(int usbSocket, int targetPort) {
    printf("Hooking usb up");
    int targetSocket = startLocalClientSocket(targetPort);
    if(targetSocket < 0) {
        close(usbSocket);
        goto free_stuff;
    }
    printf(" to socket %d.\n", targetSocket);
    pthread_t readThread;
    SocketInfo* targetRead = malloc(sizeof(SocketInfo));
    targetRead -> readingSocket = targetSocket;
    targetRead -> writingSocket = usbSocket;
    if(pthread_create(&readThread, NULL, hookSockets, targetRead) != 0) {
        printf("ERR: Failed to start the target read thread.\n");
        close(usbSocket);
        goto free_stuff;
    }

    pthread_t writeThread;
    SocketInfo* targetWrite = malloc(sizeof(SocketInfo));
    targetWrite -> readingSocket = usbSocket;
    targetWrite -> writingSocket = targetSocket;
    if(pthread_create(&writeThread, NULL, hookSockets, targetWrite) != 0) {
        printf("ERR: Failed to start the target write thread.\n");
        close(usbSocket);
        goto free_stuff;
    }

    pthread_join(readThread, NULL);
    pthread_cancel(writeThread);
    pthread_join(writeThread, NULL);
free_stuff:
    free(targetRead);
    free(targetWrite);
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
