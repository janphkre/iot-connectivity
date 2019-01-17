"
I am the main facade of this library which allows to send and receive p2p messages to the wpa_supplicant.
The wpa_supplicant control interface also allows a lot more messages to control and configure normal wifi connections as well. If such functionality is wanted one is invited to expand this library by such messages. Messages can be found in the wpa_ctrl.h C-HEADER or the help of the interactive wpa_cli command.

	service := BonjourService new: 'TestService' as: 'pharo_connectivity' with: (
		SmallDictionary newFromPairs: #('identifier' 'I am a pharo instance!')).

	device := LWpaP2PDevice onAny.
	device configure: [
		device note: 'Setting up p2p with pharo';
		flush;
		serviceAdd: service;
		serviceUpdate;
		listen ].
	device interfaces inspect.
	
The above example creates a DNS-SD service and registers it as a local service on a p2p interface. It then listens for requests in order to answer any service discovery request with the registered service.

I represent the following commands on wpa_cli:
p2p_service_add           p2p_service_flush         p2p_service_update        p2p_flush
p2p_find                  p2p_stop_find             p2p_peers                 p2p_listen
p2p_group_add             p2p_group_remove          
interfaces                ping                      flush                     note

Not implemented commands are:
p2p_asp_provision                      p2p_reject                p2p_invite
p2p_asp_provision_resp              p2p_remove_client         p2p_service_rep
p2p_cancel                p2p_serv_disc_cancel_req
p2p_connect               p2p_serv_disc_external    p2p_set
p2p_ext_listen            p2p_peer                  p2p_serv_disc_req
p2p_serv_disc_resp        p2p_unauthorize
p2p_presence_req                    
p2p_get_passphrase        p2p_prov_disc             p2p_service_del

"
Class {
	#name : #LWpaDevice,
	#superclass : #Object,
	#instVars : [
		'commandControl',
		'eventControl'
	],
	#category : #'LibWpa-Commands'
}

{ #category : #'instance creation' }
LWpaDevice class >> on: aDeviceEntry [
	| deviceFile |
	deviceFile := aDeviceEntry asFileReference.
	^ (self new) commandControl: (LWpaControl onFile: deviceFile);
	eventControl: (LWpaControl onFile: deviceFile);
	yourself.
]

{ #category : #'instance creation' }
LWpaDevice class >> onAny [
	^ self on: LWpaControl anyDevice.
]

{ #category : #'instance creation' }
LWpaDevice class >> onAnyP2P [
	^ self on: LWpaControl anyP2PDevice.
]

{ #category : #accessing }
LWpaDevice >> commandControl [
	^ commandControl
]

{ #category : #accessing }
LWpaDevice >> commandControl: aLWpaControl [
	commandControl := aLWpaControl
]

{ #category : #configuration }
LWpaDevice >> configure: aBlock [
	"Define a sequence of commands in the block to configure this device.
	This sequence will be replayed on every start of the vm.
	Please be aware that you are probably sending commands when
	replying to events so you should run this configuration sequence
	before registering a event listener.
	Multiple configure blocks can be run.
	Each sequence of commands will then be appended to the previous one."
	commandControl startRecording.
	eventControl startRecording.
	aBlock value.
	commandControl stopRecording.
	eventControl stopRecording.
]

{ #category : #accessing }
LWpaDevice >> eventControl [
	^ eventControl
]

{ #category : #accessing }
LWpaDevice >> eventControl: aLWpaControl [
	eventControl := aLWpaControl
]

{ #category : #commands }
LWpaDevice >> flush [ 
	"Flushes the interface."
	commandControl flush.
]

{ #category : #configuration }
LWpaDevice >> forgetConfiguration [
	commandControl forgetRecording.
	eventControl forgetRecording.
]

{ #category : #accessing }
LWpaDevice >> interface: aDeviceString [
	self forgetConfiguration.
	self stopReceive.
	self commandControl: (LWpaControl on: aDeviceString).
	self eventControl: (LWpaControl on: aDeviceString).
	
]

{ #category : #commands }
LWpaDevice >> interfaces [
	^ (commandControl command: 'INTERFACES') lines.
]

{ #category : #commands }
LWpaDevice >> listNetworks [
	^ (commandControl command: 'LIST_NETWORKS') lines allButFirst.
]

{ #category : #commands }
LWpaDevice >> note: aString [
	"Add a note to the wpa_supplicant debug log."
	^ (commandControl command: ('NOTE ', aString)) isOk
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pFind [
	"Finds nearby devices as possible peers.
	This is a async call and the given block will return all findings.
	Success is indicated by the return value being true."
	^ (commandControl command: 'P2P_FIND') isOk
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pGroupAdd [
	"Set up this device as an autonomous group owner."
	^ (commandControl command: 'P2P_GROUP_ADD') isOk

]

{ #category : #'p2p commands' }
LWpaDevice >> p2pGroupRemove: aString [
	"Remove the group with the given network id string."
	^ (commandControl command: ('P2P_GROUP_REMOVE ', aString)) isOk
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pListen [
	"Listens for events and peers without sending any active p2p requests. Replies to Service Discovery and Find requests though."
	^ (commandControl command: 'P2P_LISTEN') isOk 
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pPeers [
	"Gives an array of possible peers found through find:"
	^ (commandControl command: 'P2P_PEERS') lines
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pServiceAdd: aLWpaService [
	"Add a local service to service discovery"
	^ (commandControl command: ('P2P_SERVICE_ADD ', aLWpaService build)) isOk
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pServiceFlush [
	^ (commandControl command: 'P2P_SERVICE_FLUSH') isOk
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pServiceRespond: services on: frequency to: destination [
	^ (commandControl command: ('P2P_SERV_DISC_RESP ', frequency, ' ', destination, ' ', services)) isOk.
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pServiceUpdate [
	"Updates the service counter to indicate that available services on this device have changed."
	^ (commandControl command: 'P2P_SERVICE_UPDATE') isOk
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pSsidPostfix: aString [
	^ (commandControl command: ('P2P_SET ssid_postfix ', aString)) isOk
]

{ #category : #'p2p commands' }
LWpaDevice >> p2pStopFind [
	"Stops the discovery of nearby devices started by find:
	Success is indicated by the return value being true."
	^ (commandControl command: 'P2P_STOP_FIND') isOk
]

{ #category : #events }
LWpaDevice >> receiveEvents: aBlock [
	
	eventControl attach: [ :eventString |
		| event |
		event := LWpaEvent from: eventString.
		event ifNotNil: [ aBlock value: event ] ].
]

{ #category : #commands }
LWpaDevice >> scan [
	"Start a scan for available networks"
	^ (commandControl command: 'SCAN') isOk
]

{ #category : #commands }
LWpaDevice >> scanResults [
	"Start a scan for available networks"
	^ (commandControl command: 'SCAN_RESULTS') lines allButFirst.
]

{ #category : #commands }
LWpaDevice >> status [
	^ (commandControl command: 'STATUS') lines.
]

{ #category : #events }
LWpaDevice >> stopReceive [
	eventControl detach.
]