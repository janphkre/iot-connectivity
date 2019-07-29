//Requires: sudo apt-get install libbluetooth-dev libdbus-1-dev

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <bluetooth/rfcomm.h>
#include <dbus/dbus.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define BUF_SIZE 8192
#define LISTEN_QUEUE_SIZE 4
#define DBUS_MPRIS_BUS_NAME "com.github.janphkre.httpwrapper"
#define DBUS_INSTANCE_ID_PREFIX "instance"

int startBluetoothServerSocket(int bluetoothPort, bdaddr_t bdaddr);
int acceptBluetoothSocket(int serverSocket);
void hookBluetoothSocket(int bluetoothSocket, int targetPort);
int startLocalClientSocket(int targetPort);
int pipeData(int sourceSocket, int targetSocket, char* buffer);
int generateUuid(bdaddr_t bdaddr, const char* service_name, uint32_t* uuid);
int defineService(bdaddr_t bdaddr, const char* service_name, DBusConnection** conn);
int setubDbus();
int registerUuidDbus(const char* bluetoothDevice, const char* uuidString);
int handleUuidDbusReply(DBusPendingCall* pending);

int main(int argc, char **argv) {
    int serverPort, bluetoothPort, bluetoothDevice;
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
    service_name = argv[4];
    if(sizeof(service_name) < 8) {
        printf("ERR: The service name should have at least 8 letters.\n");
        return -5;
    }

    bdaddr_t bdaddr = { 0 };
    if(hci_devba(bluetoothDevice, &bdaddr) < 0) {
        printf("ERR: No device found for the given device id %i.\n", bluetoothDevice);
        return -6;
    }
    int bluetoothSocket = startBluetoothServerSocket(bluetoothPort, bdaddr);
    if (bluetoothSocket < 0) {
        return -7;
    }

    const char* bluetoothDeviceString = strcat("hci", argv[3]);
    DBusConnection* conn;
    const char* uuidString = generateUuid(bdaddr, service_name, service_uuid_int);

    if (defineService(bluetoothPort, bdaddr, bluetoothDeviceString, service_name, "", "", &conn, uuidString)) {
        printf("ERR: Failed to define the service!\n");
        if(NULL != conn) {
            dbus_connection_close(conn);
        }
        close(bluetoothSocket);
        return -8;
    }
return 0;
    while(1) {
        int client = acceptBluetoothSocket(bluetoothSocket);
        hookBluetoothSocket(client, serverPort);
    }
    unregisterUuidDbus(bluetoothDeviceString, uuidString);//TODO!
    dbus_connection_close(conn);
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
    loc_addr.rc_bdaddr = bdaddr;
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
    return accept(serverSocket, (struct sockaddr *)&rem_addr, &opt);
}

void hookBluetoothSocket(int bluetoothSocket, int targetPort) {
    char buffer[BUF_SIZE] = { 0 };
    int clientSocket = startLocalClientSocket(targetPort);
    while(1) {
        if(pipeData(bluetoothSocket, clientSocket, buffer) < 0) {
            break;
        }
        if(pipeData(clientSocket, bluetoothSocket, buffer) < 0) {
            break;
        }
    }

    close(bluetoothSocket);
    close(clientSocket);
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
        printf("ERR: Connect failed.\n");
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

int generateUuid(bdaddr_t bdaddr, const char* service_name, uint32_t* uuid) {
    uint8_t* macAddress = (uint8_t*) &bdaddr;
    char macAddressString[18];
    ba2str(&bdaddr, macAddressString);
    printf("Mac address is: %s\n", macAddressString);

    uuid[0] = macAddress[0];
    uuid[0] = (uuid[0] << 8) + macAddress[1];
    uuid[0] = (uuid[0] << 8) + macAddress[2];
    uuid[0] = (uuid[0] << 8) + macAddress[3];
    uuid[1] = (macAddress[4] << 8) + macAddress[5];
    uuid[2] = service_name[0];
    uuid[2] = (uuid[2] << 8) + service_name[1];
    uuid[2] = (uuid[2] << 8) + service_name[2];
    uuid[2] = (uuid[0] << 8) + service_name[3];
    uuid[3] = service_name[4];
    uuid[3] = (uuid[3] << 8) + service_name[5];
    uuid[3] = (uuid[3] << 8) + service_name[6];
    uuid[3] = (uuid[3] << 8) + service_name[7];
    return 0;
}

// Mostly taken from: https://people.csail.mit.edu/albert/bluez-intro/x604.html
int defineService(bdaddr_t bdaddr, const char* service_name, DBusConnection** conn) {
    uint32_t uuid[4] = { 0, 0, 0, 0 };
    if(generateUuid(bdaddr, service_name, uuid) < 0) {
        return -1;
    }
    //TODO: CONVERT UUID INT ARRAY TO STRING!!!
    if(setupDbus(conn) < 0) {
        return -2;
    }
    
    if(registerUuidDbus() < 0) {
        dbus_connection_close(*conn);
        return -3;
    }

    return 0;
}

//Taken from http://www.matthew.ath.cx/misc/dbus
int setubDbus(DBusConnection** conn) {
    DBusError err;
    int ret;
    // initialise the errors
    dbus_error_init(&err);

    // connect to the bus
    *conn = dbus_bus_get(DBUS_BUS_SESSION, &err);
    if (dbus_error_is_set(&err)) { 
        printf("ERR: Failed DBus connection (%s)\n", err.message); 
        dbus_error_free(&err); 
    }
    if (NULL == conn) { 
        return -1;
    }
    return 0;
}

//Taken from http://www.matthew.ath.cx/misc/dbus
//Documentation for bluez method can be found at https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc/network-api.txt
int registerUuidDbus(DBusConnection* conn, const char* bluetoothDevice, const char* uuidString, uint16_t bluetoothPort) {
    DBusMessage* msg;
    DBusMessageIter args, options, entry, variant;
    DBusPendingCall* pending;
    char* portKey, uniqueName;
    char unique_service[sizeof( DBUS_MPRIS_BUS_NAME ) + sizeof( DBUS_INSTANCE_ID_PREFIX ) + sizeof(uniqueName)];

    uniqueName = dbus_bus_get_unique_name(conn);

    snprintf( unique_service, sizeof (unique_service), DBUS_MPRIS_BUS_NAME"."DBUS_INSTANCE_ID_PREFIX""uniqueName);

    if( dbus_bus_request_name( conn, unique_service, 0, NULL) != DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER) {
        printf("ERR: DBus Object could not be obtained\n");
        return -1;
    }
    msg = dbus_message_new_method_call("org.bluez", // target for the method call
        "/org/bluez", // object to call on
        "org.bluez.ProfileManager1", // interface to call on
        "RegisterProfile"); // method name
    if (NULL == msg) { 
        printf("ERR: DBus Message Null\n");
        return -2;
    }

    // append arguments
    dbus_message_iter_init_append(msg, &args);
    if (!dbus_message_iter_append_basic(&args, DBUS_TYPE_OBJECT, &unique_service)) { 
        printf("ERR: DBus Out Of Memory!\n"); 
        return -3;
    }
    if (!dbus_message_iter_append_basic(&args, DBUS_TYPE_STRING, &uuidString)) { 
        printf("ERR: DBus Out Of Memory!\n"); 
        return -4;
    }

    portKey = "port";
    //Dictionary entry type is "string variant"
    dbus_message_iter_open_container( args, DBUS_TYPE_ARRAY, "{sv}", &options);
    dbus_message_iter_open_container(&options, DBUS_TYPE_DICT_ENTRY, NULL, &entry);
    dbus_message_iter_append_basic(&entry, DBUS_TYPE_STRING, &portKey);
    dbus_message_iter_open_container(&entry, DBUS_TYPE_VARIANT, DBUS_TYPE_UINT16_AS_STRING, &variant);
    dbus_message_iter_append_basic(&variant, DBUS_TYPE_UINT16, &bluetoothPort);
    dbus_message_iter_close_container(&entry, &variant);
    dbus_message_iter_close_container(&options, &entry);
    dbus_message_iter_close_container(&args, &options);

    // send message and get a handle for a reply
    if (!dbus_connection_send_with_reply (conn, msg, &pending, -1)) { // -1 is default timeout
        dbus_message_unref(msg);
        printf("ERR: DBus Out Of Memory!\n"); 
        return -10;
    }
    if (NULL == pending) {
        dbus_message_unref(msg);
        printf("ERR: Pending Call Null\n"); 
        return -11;
    }
    dbus_connection_flush(conn);

    // free message
    dbus_message_unref(msg);

    return handleUuidDbusReply(pending);
}

//Taken from http://www.matthew.ath.cx/misc/dbus
int handleUuidDbusReply(DBusPendingCall* pending) {
    // block until we receive a reply
    dbus_pending_call_block(pending);
    return 0;
}
