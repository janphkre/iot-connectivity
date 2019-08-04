//Requires: sudo apt-get install libbluetooth-dev libdbus-1-dev

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <dbus/dbus.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define BUF_SIZE 8192
#define UUID_BYTES 16
#define PROFILE_PATH "/HttpWrapper"
#define DBUS_TIMEOUT 30000

volatile int shouldLoop = TRUE;
volatile int current_fd = -1;
static sem_t semaphore;
static int serverPort;

typedef struct {
    int readingSocket;
    int writingSocket;
} SocketInfo;

int acquireSocket();
int startHookingThread(pthread_t* thread);
void* hookingThread(void* data);
void hookBluetoothSocket(int bluetoothSocket, int targetPort);
void* hookSockets(void* data);
int startLocalClientSocket(int targetPort);
int pipeData(int sourceSocket, int targetSocket, char* buffer);
int generateUuid(bdaddr_t bdaddr, const char* service_name, uint8_t* uuid);
int defineService(bdaddr_t bdaddr, const char* service_name, DBusConnection* conn, uint16_t bluetoothPort);
int setupDbus(DBusConnection** conn);
int registerUuidDbus(DBusConnection* conn, const char* uuidString, uint16_t bluetoothPort);
int registerProfileDbus(DBusConnection* conn);
static DBusHandlerResult wrapper_messages(DBusConnection *connection, DBusMessage *message, void *user_data);
void profileRelease();
int profileNewConnection(DBusMessage *request);
void profileRequestDisconnection();

int main(int argc, char **argv) {
    int bluetoothPort, bluetoothDevice;
    char* service_name;

    if(argc != 5) {
        printf("Usage:\nWrappes a server in a bluetooth connection.\nFirst argument is the server port,\nSecond is the desired bluetooth port,\nThird is the bluetooth device id,\nFourth is the service name.\n");
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
    printf("Using service %s\n", argv[4]);
    service_name = argv[4];
    if(strlen(service_name) < 12) {
        printf("ERR: The service name should have at least 11 characters. (%ld)\n", sizeof(service_name));
        return -5;
    }

    bdaddr_t bdaddr = { 0 };
    if(hci_devba(bluetoothDevice, &bdaddr) < 0) {
        printf("ERR: No device found for the given device id %i.\n", bluetoothDevice);
        return -10;
    }

    DBusConnection* conn;
    if(setupDbus(&conn) < 0) {
        return -11;
    }


    if(defineService(bdaddr, service_name, conn, bluetoothPort) < 0) {
        printf("ERR: Failed to define the service!\n");
        return -13;
    }

    if(sem_init(&semaphore, 0, 0) < 0) {
        printf("ERR: Failed to create a semaphore!\n");
        return -12;
    }

    if(registerProfileDbus(conn) < 0) {
        sem_destroy(&semaphore);
        return -14;
    }

//TODO:
    /*if(startDbusDiscoverability() < 0) {
       printf("ERR: Failed start discovery!\n");
        close(bluetoothSocket);
        return -14;
    }*/

    pthread_t thread;
    if(startHookingThread(&thread) < 0) {
        profileRequestDisconnection();
        sem_destroy(&semaphore);
        return -15;
    }

    while(shouldLoop) {
        dbus_connection_read_write_dispatch(conn, DBUS_TIMEOUT);
    }

    pthread_cancel(thread);
    profileRequestDisconnection();
    sem_destroy(&semaphore);
    printf("\n");
    return 0;
}

int acquireSocket() {
    printf("Awaiting connection...\n");
    int fd;
    sem_wait(&semaphore);
    fd = current_fd;
    if(fd < 0) {
        return -1;
    }
    return fd;
}

int startHookingThread(pthread_t* thread) {
    if(pthread_create(thread, NULL, hookingThread, NULL) != 0) {
        printf("ERR: Failed to start the hooking thread.\n");
        return -1;
    }
    return 0;
}

void* hookingThread(void* data) {
    int targetPort = serverPort;
    while(shouldLoop) {
        int client = acquireSocket();
        if(client < 0) {
            printf("ERR: Accept failed.\n");
            continue;
        }
        printf("Hooking socket up to %d.\n", targetPort);
        int targetSocket = startLocalClientSocket(targetPort);
        if(targetSocket < 0) {
            goto free_stuff;
        }

        pthread_t readThread;
        SocketInfo* targetRead = malloc(sizeof(SocketInfo));
        targetRead -> readingSocket = client;
        targetRead -> writingSocket = targetSocket;
        if(pthread_create(&readThread, NULL, hookSockets, targetRead) != 0) {
            printf("ERR: Failed to start the target read thread.\n");
            goto free_stuff;
        }

        pthread_t writeThread;
        SocketInfo* targetWrite = malloc(sizeof(SocketInfo));
        targetWrite -> readingSocket = targetSocket;
        targetWrite -> writingSocket = client;
        if(pthread_create(&writeThread, NULL, hookSockets, targetWrite) != 0) {
            printf("ERR: Failed to start the target write thread.\n");
            goto free_stuff;
        }

        pthread_join(readThread, NULL);
        pthread_join(writeThread, NULL);
free_stuff:
        free(targetRead);
        free(targetWrite);
        close(client);
        close(targetSocket);
    }
    return NULL;
}

void* hookSockets(void* data) {
    SocketInfo sockets = *((SocketInfo*) data);
    char buffer[BUF_SIZE] = { 0 };
    while(shouldLoop) {
        if(pipeData(sockets.readingSocket, sockets.writingSocket, buffer) < 0) {
            break;
        }
    }
    return NULL;
}

int startLocalClientSocket(int targetPort) {
    int s;
    struct sockaddr_in rem_addr = { 0 };

    //Create socket
    s = socket(AF_INET, SOCK_STREAM , 0);
    if (s == -1) {
        printf("ERR: Could not create local socket.\n");
        return -1;
    }

    //Connect to local server
    rem_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    rem_addr.sin_family = AF_INET;
    rem_addr.sin_port = htons(targetPort);
    if (connect(s, (struct sockaddr *)&rem_addr , sizeof(rem_addr)) < 0) {
        printf("ERR: Connect failed.\n");//TODO FAILING HERE!
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

    printf("Piping: from %d to %d\n", sourceSocket, targetSocket);
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

// Adapted from: https://www.cryptosys.net/pki/Uuid.c.html
int generateUuid(bdaddr_t bdaddr, const char* service_name, uint8_t* uuid) {
    char macAddressString[18];
    ba2str(&bdaddr, macAddressString);
    printf("Mac address is: %s\n", macAddressString);

    memcpy(&uuid[0], &bdaddr, 6);
    memcpy(&uuid[6], service_name, 11);
    // 2. Adjust certain bits according to RFC 4122 section 4.4.
    // This just means do the following
    // (a) set the high nibble of the 7th byte equal to 4 and
    // (b) set the two most significant bits of the 9th byte to 10'B,
    //     so the high nibble will be one of {8,9,A,B}.
    uuid[6] = 0x40 | (uuid[6] & 0xf);
    uuid[8] = 0x80 | (uuid[8] & 0x3f);

    return 0;
}

// Mostly taken from: https://leonardoce.wordpress.com/2015/03/11/dbus-tutorial-using-the-low-level-api/
int defineService(bdaddr_t bdaddr, const char* service_name, DBusConnection* conn, uint16_t bluetoothPort) {
    uint8_t uuid[UUID_BYTES];
    memset(uuid, 0, UUID_BYTES);
    if(generateUuid(bdaddr, service_name, uuid) < 0) {
        return -1;
    }

    char uuidString[37];
    for(int i=0;i<4;i++) {
        sprintf(&uuidString[i*2+0], "%02x", uuid[i]);
    }
    uuidString[8] = '-';
    for(int i=0;i<2;i++) {
        sprintf(&uuidString[i*2+9], "%02x", uuid[i+4]);
    }
    uuidString[13] = '-';
    for(int i=0;i<4;i++) {
        sprintf(&uuidString[i*2+14], "%02x", uuid[i+6]);
    }
    uuidString[18] = '-';
    for(int i=0;i<2;i++) {
        sprintf(&uuidString[i*2+19], "%02x", uuid[i+8]);
    }
    uuidString[23] = '-';
    for(int i=0;i<6;i++) {
        sprintf(&uuidString[i*2+24], "%02x", uuid[i+10]);
    }
    uuidString[36] = '\0';
    
    printf("Using Uuid: %s\n", uuidString);

    if(registerUuidDbus(conn, uuidString, bluetoothPort) < 0) {
        return -3;
    }

    return 0;
}

//Taken from http://www.matthew.ath.cx/misc/dbus
int setupDbus(DBusConnection** conn) {
    DBusError err;
    // initialise the errors
    dbus_error_init(&err);

    // connect to the bus
    *conn = dbus_bus_get(DBUS_BUS_SYSTEM, &err);
    if (dbus_error_is_set(&err)) { 
        printf("ERR: Failed DBus connection (%s)\n", err.message); 
        dbus_error_free(&err);
        return -1;
    }
    dbus_error_free(&err); 
    if (NULL == conn) { 
        return -2;
    }
    return 0;
}

//Taken from http://www.matthew.ath.cx/misc/dbus
//Documentation for bluez method can be found at https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc/network-api.txt
int registerUuidDbus(DBusConnection* conn, const char* uuidString, uint16_t bluetoothPort) {
    DBusMessage *msg;
    DBusMessageIter args, options, entry, variant;
    char *key, *value;

    msg = dbus_message_new_method_call("org.bluez", // target for the method call
        "/org/bluez", // object to call on
        "org.bluez.ProfileManager1", // interface to call on
        "RegisterProfile"); // method name
    if (NULL == msg) { 
        printf("ERR: DBus Message Null\n");
        return -2;
    }

    // append arguments
    const char* service_path = PROFILE_PATH;
    dbus_message_iter_init_append(msg, &args);
    if (!dbus_message_iter_append_basic(&args, DBUS_TYPE_OBJECT_PATH, &service_path)) {
        printf("ERR: DBus Out Of Memory!\n"); 
        return -3;
    }
    if (!dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &uuidString)) { 
        printf("ERR: DBus Out Of Memory!\n"); 
        return -4;
    }

    dbus_message_iter_open_container(&args, DBUS_TYPE_ARRAY, "{sv}", &options);


    key = "Channel";
    dbus_message_iter_open_container(&options, DBUS_TYPE_DICT_ENTRY, NULL, &entry);
    dbus_message_iter_append_basic(&entry, DBUS_TYPE_STRING, &key);
    dbus_message_iter_open_container(&entry, DBUS_TYPE_VARIANT, DBUS_TYPE_UINT16_AS_STRING, &variant);
    dbus_message_iter_append_basic(&variant, DBUS_TYPE_UINT16, &bluetoothPort);
    dbus_message_iter_close_container(&entry, &variant);
    dbus_message_iter_close_container(&options, &entry);

    key = "Name";
    value = "Port-Wrapper";
    dbus_message_iter_open_container(&options, DBUS_TYPE_DICT_ENTRY, NULL, &entry);
    dbus_message_iter_append_basic(&entry, DBUS_TYPE_STRING, &key);
    dbus_message_iter_open_container(&entry, DBUS_TYPE_VARIANT, DBUS_TYPE_STRING_AS_STRING, &variant);
    dbus_message_iter_append_basic(&variant, DBUS_TYPE_STRING, &value);
    dbus_message_iter_close_container(&entry, &variant);
    dbus_message_iter_close_container(&options, &entry);

    key = "Role";
    value = "server";
    dbus_message_iter_open_container(&options, DBUS_TYPE_DICT_ENTRY, NULL, &entry);
    dbus_message_iter_append_basic(&entry, DBUS_TYPE_STRING, &key);
    dbus_message_iter_open_container(&entry, DBUS_TYPE_VARIANT, DBUS_TYPE_STRING_AS_STRING, &variant);
    dbus_message_iter_append_basic(&variant, DBUS_TYPE_STRING, &value);
    dbus_message_iter_close_container(&entry, &variant);
    dbus_message_iter_close_container(&options, &entry);

    key = "RequireAuthentication";
    int boolean = FALSE;
    dbus_message_iter_open_container(&options, DBUS_TYPE_DICT_ENTRY, NULL, &entry);
    dbus_message_iter_append_basic(&entry, DBUS_TYPE_STRING, &key);
    dbus_message_iter_open_container(&entry, DBUS_TYPE_VARIANT, DBUS_TYPE_BOOLEAN_AS_STRING, &variant);
    dbus_message_iter_append_basic(&variant, DBUS_TYPE_BOOLEAN, &boolean);
    dbus_message_iter_close_container(&entry, &variant);
    dbus_message_iter_close_container(&options, &entry);

    key = "RequireAuthorization";
    boolean = FALSE;
    dbus_message_iter_open_container(&options, DBUS_TYPE_DICT_ENTRY, NULL, &entry);
    dbus_message_iter_append_basic(&entry, DBUS_TYPE_STRING, &key);
    dbus_message_iter_open_container(&entry, DBUS_TYPE_VARIANT, DBUS_TYPE_BOOLEAN_AS_STRING, &variant);
    dbus_message_iter_append_basic(&variant, DBUS_TYPE_BOOLEAN, &boolean);
    dbus_message_iter_close_container(&entry, &variant);
    dbus_message_iter_close_container(&options, &entry);


    dbus_message_iter_close_container(&args, &options);

    // send message and get a handle for a reply
    DBusError err;
    // initialise the errors
    dbus_error_init(&err);
    if (!dbus_connection_send_with_reply_and_block (conn, msg, -1, &err)) { // -1 is default timeout
        printf("ERR: Failed DBus Send request (%s)\n", err.message); 
        dbus_message_unref(msg);
        dbus_error_free(&err); 
        return -10;
    }

    dbus_error_free(&err); 
    dbus_connection_flush(conn);
    dbus_message_unref(msg);

    return 0;
}

/* Mostly taken from https://leonardoce.wordpress.com/2015/04/01/dbus-tutorial-a-simple-server/ */
int registerProfileDbus(DBusConnection* conn) {
    DBusError err;
    DBusObjectPathVTable vtable;
    // initialise the errors
    dbus_error_init(&err);

    vtable.message_function = wrapper_messages;
    vtable.unregister_function = NULL;

    dbus_connection_try_register_object_path(conn,
        PROFILE_PATH,
        &vtable, NULL, &err);
    if (dbus_error_is_set(&err)) {
        printf("ERR: Failed DBus register object (%s)\n", err.message);
        dbus_error_free(&err);
        return -2;
    }

    dbus_error_free(&err);
    return 0;
}

/* Mostly taken from https://leonardoce.wordpress.com/2015/04/01/dbus-tutorial-a-simple-server/ */
static DBusHandlerResult wrapper_messages(DBusConnection *connection, DBusMessage *message, void *user_data) {
    const char *interface_name = dbus_message_get_interface(message);
        const char *member_name = dbus_message_get_member(message);

        if (0==strcmp("org.bluez.Profile1", interface_name)) {
            if(0==strcmp("Release", member_name)) {
                profileRelease();
                return DBUS_HANDLER_RESULT_HANDLED;
            } else if(0==strcmp("NewConnection", member_name)) {
                profileNewConnection(message);
                return DBUS_HANDLER_RESULT_HANDLED;
            } else if(0==strcmp("RequestDisconnection", member_name)) {
                profileRequestDisconnection();
                return DBUS_HANDLER_RESULT_HANDLED;
            }

        }
        return DBUS_HANDLER_RESULT_NOT_YET_HANDLED;
}

void profileRelease() {
    shouldLoop = FALSE;
}

int profileNewConnection(DBusMessage *request) {
    int fd;
    DBusError error;
    dbus_error_init(&error);

    dbus_message_get_args(request, &error,
    DBUS_TYPE_INVALID,
    DBUS_TYPE_UNIX_FD, &fd,
    DBUS_TYPE_INVALID);
    if (dbus_error_is_set(&error)) {
        printf("ERR: Failed DBus obtian param (%s)\n", error.message);
        dbus_error_free(&error);
        return -1;
    }

    sem_trywait(&semaphore);
    current_fd = fd;
    sem_post(&semaphore);

    dbus_error_free(&error);
    return 0;
}

void profileRequestDisconnection() {
    sem_trywait(&semaphore);
    if(current_fd > 0) {
        close(current_fd);
        current_fd = -1;
    }
}
