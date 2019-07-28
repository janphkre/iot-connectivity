//Requires: sudo apt-get install libbluetooth-dev

#include <bluetooth/bluetooth.h>
#include <bluetooth/hci.h>
#include <bluetooth/hci_lib.h>
#include <bluetooth/rfcomm.h>
#include <bluetooth/sdp.h>
#include <bluetooth/sdp_lib.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define BUF_SIZE 8192
#define LISTEN_QUEUE_SIZE 4

int startBluetoothServerSocket(int bluetoothPort, bdaddr_t bdaddr);
int acceptBluetoothSocket(int serverSocket);
void hookBluetoothSocket(int bluetoothSocket, int targetPort);
int startLocalClientSocket(int targetPort);
int pipeData(int sourceSocket, int targetSocket, char* buffer);
int generateUuid(bdaddr_t bdaddr, const char* service_name, uint32_t* uuid);
int defineService(int bluetoothPort, bdaddr_t bdaddr, const char* service_name, const char* service_dsc, const char* service_prov, sdp_session_t** session);

int main(int argc, char **argv) {
    int serverPort, bluetoothPort, bluetoothDevice;
    char* service_name;

    if(argc != 5) {
        printf("Usage:\nWrappes a server in a bluetooth connection.\nFirst argument is the server port,\n Second is the desired bluetooth port,\nThird is the bluetooth device id,\nFourth is the service name.");
    }
    if (sscanf (argv[1], "%i", &serverPort) != 1) {
        printf("ERR: Server port is not an integer!");
        return -1;
    }
    if (sscanf (argv[2], "%i", &bluetoothPort) != 1) {
        printf("ERR: Bluetooth port is not an integer!");
        return -2;
    }
    if (sscanf (argv[3], "%i", &bluetoothDevice) != 1) {
        printf("ERR: Bluetooth device id is not an integer!");
        return -3;
    }
    service_name = argv[4];
    if(sizeof(service_name) < 8) {
        printf("ERR: The service name should have at least 6 letters.");
        return -5;
    }

    bdaddr_t bdaddr = { 0 };
    hci_devba(bluetoothDevice, &bdaddr);
    int bluetoothSocket = startBluetoothServerSocket(bluetoothPort, bdaddr);

    if (bluetoothSocket < 0) {
        return -6;
    }

    sdp_session_t* sdpSession;
    if (defineService(bluetoothPort, bdaddr, service_name, "", "", &sdpSession)) {
        printf("ERR: Failed to define the service!");
        sdp_close(sdpSession);
        close(bluetoothSocket);
        return -7;
    }
    while(1) {
        int client = acceptBluetoothSocket(bluetoothSocket);
        hookBluetoothSocket(client, serverPort);
    }
    sdp_close(sdpSession);
    close(bluetoothSocket);
    return 0;
}

//Mostly taken from : https://people.csail.mit.edu/albert/bluez-intro/x502.html#rfcomm-server.c
int startBluetoothServerSocket(int bluetoothPort, bdaddr_t bdaddr) {
    struct sockaddr_rc loc_addr = { 0 };
    int s;

    // allocate socket
    s = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);
    if (s == -1) {
        printf("ERR: Could not create socket");
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
        printf("ERR: Failed to listen on socket.");
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
        printf("ERR: Could not create socket");
        return -1;
    }

    //Connect to local server
    rem_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    rem_addr.sin_family = AF_INET;
    rem_addr.sin_port = htons(targetPort);

    if (connect(s, (struct sockaddr *)&rem_addr , sizeof(rem_addr)) < 0) {
        printf("ERR: Connect failed.");
        close(s);
        return -2;
    }
    return s;
}

int pipeData(int sourceSocket, int targetSocket, char* buffer) {
    int bytes_read, bytes_sent;

    bytes_read = read(sourceSocket, buffer, BUF_SIZE);
    if(bytes_read < 0) {
        printf("ERR: recv failed");
        return -1;
    }

    bytes_sent = send(targetSocket, buffer, bytes_read, 0);
    if(bytes_sent < 0) {
        printf("ERR: send failed");
        return -2;
    }

    if(bytes_read != bytes_sent) {
        printf("ERR: Read %d bytes but sent %d bytes", bytes_read, bytes_sent);
        //TODO: THIS MAY INDICATE A FAILURE
    }
    memset(buffer, 0, BUF_SIZE);
    return 0;
}

int generateUuid(bdaddr_t bdaddr, const char* service_name, uint32_t* uuid) {
    uint8_t* macAddress = (uint8_t*) &bdaddr;
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
int defineService(int bluetoothPort, bdaddr_t bdaddr, const char* service_name, const char* service_dsc, const char* service_prov, sdp_session_t** session) {
    uint32_t service_uuid_int[] = { 0, 0, 0, 0 };
    uint8_t rfcomm_channel = (uint8_t) bluetoothPort;

    uuid_t root_uuid, rfcomm_uuid, svc_uuid;
    sdp_list_t *rfcomm_list = 0,
               *root_list = 0,
               *proto_list = 0, 
               *access_proto_list = 0;
    sdp_data_t *channel = 0;

    sdp_record_t *record = sdp_record_alloc();

    //generate UUID
    if(generateUuid(bdaddr, service_name, service_uuid_int) < 0) {
        return -1;
    }

    // set the general service ID
    sdp_uuid128_create( &svc_uuid, &service_uuid_int );
    sdp_set_service_id( record, svc_uuid );

    // make the service record publicly browsable
    sdp_uuid16_create(&root_uuid, PUBLIC_BROWSE_GROUP);
    root_list = sdp_list_append(0, &root_uuid);
    sdp_set_browse_groups( record, root_list );

    // set rfcomm information
    sdp_uuid16_create(&rfcomm_uuid, (uint16_t) service_uuid_int[2]);//TODO: cast MAY BE INCORRECT
    channel = sdp_data_alloc(SDP_UINT8, &rfcomm_channel);
    rfcomm_list = sdp_list_append( 0, &rfcomm_uuid );
    sdp_list_append( rfcomm_list, channel );
    sdp_list_append( proto_list, rfcomm_list );

    // attach protocol information to service record
    access_proto_list = sdp_list_append( 0, proto_list );
    sdp_set_access_protos( record, access_proto_list );

    // set the name, provider, and description
    sdp_set_info_attr(record, service_name, service_prov, service_dsc);


    int err = 0;

    // connect to the local SDP server, register the service record, and 
    // disconnect
    *session = sdp_connect(&bdaddr, BDADDR_LOCAL, SDP_RETRY_IF_BUSY);//TODO: bdaddr may have to revert back to BDADDR_ANY
    err = sdp_record_register(*session, record, 0);

    // cleanup
    sdp_data_free(channel);
    sdp_list_free(rfcomm_list, 0);
    sdp_list_free(root_list, 0);
    sdp_list_free(access_proto_list, 0);

    if(err < 0) {
        return -2;
    }
    return 0;
}
