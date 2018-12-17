"
I am the main facade of this library which allows to send and receive p2p messages to the wpa_supplicant.
The wpa_supplicant control interface also allows a lot more messages to control and configure normal wifi connections as well. If such functionality is wanted one is invited to expand this library by such messages. Messages can be found in the wpa_ctrl.h C-HEADER or the help of the interactive wpa_cli command.

	service := BonjourService new: 'TestService' as: 'pharo_connectivity' with: (
		SmallDictionary newFromPairs: #('identifier' 'I am a pharo instance!')).

	device := LWpaP2PDevice onAny.
	device serviceFlush.
	device serviceAdd: service.
	device listen.
	
The above example creates a DNS-SD service and registers it as a local service on a p2p interface. It then listens for requests in order to answer any service discovery request with the registered service.
"
Class {
	#name : #LWpaP2PDevice,
	#superclass : #Object,
	#instVars : [
		'commandControl',
		'eventControl'
	],
	#category : #'LibWpa-Commands'
}

{ #category : #'instance creation' }
LWpaP2PDevice class >> on: p2pDevicePath [
	^ (self new) commandControl: (LWpaControl onFile: p2pDevicePath);
	eventControl: (LWpaControl onFile: p2pDevicePath);
	yourself.
]

{ #category : #'instance creation' }
LWpaP2PDevice class >> onAny [
	^ self on: LWpaControl anyP2PDevice.
]

{ #category : #accessing }
LWpaP2PDevice >> commandControl [
	^ commandControl
]

{ #category : #accessing }
LWpaP2PDevice >> commandControl: aLWpaControl [
	commandControl := aLWpaControl
]

{ #category : #configuration }
LWpaP2PDevice >> configure [
	"Define a sequence of commands to configure this device.
	This sequence will be replayed on every start of the vm.
	Please be aware that you are probably sending commands when
	replying to events so you should run this configuration sequence
	before registering a event listener."
	commandControl startRecording.
	eventControl startRecording.
]

{ #category : #accessing }
LWpaP2PDevice >> eventControl [
	^ eventControl
]

{ #category : #accessing }
LWpaP2PDevice >> eventControl: aLWpaControl [
	eventControl := aLWpaControl
]

{ #category : #commands }
LWpaP2PDevice >> find [
	"Finds nearby devices as possible peers.
	This is a async call and the given block will return all findings.
	Success is indicated by the return value being true."
	^ (commandControl command: 'P2P_FIND') isOk
]

{ #category : #commands }
LWpaP2PDevice >> flush [ 
	"Flushes the configuration for the interface.
	If this returns false you may want to use another interface."
  ^ (commandControl command: 'P2P_FLUSH') isOk
]

{ #category : #configuration }
LWpaP2PDevice >> forgetConfiguration [
	commandControl forgetRecording.
	eventControl forgetRecording.
]

{ #category : #commands }
LWpaP2PDevice >> listen [
	"Listens for events and peers without sending any active p2p requests. Replies to Service Discovery and Find requests though."
	^ (commandControl command: 'P2P_LISTEN') isOk 
]

{ #category : #commands }
LWpaP2PDevice >> peers [
	"Gives an array of possible peers found through find:"
	^ (commandControl command: 'P2P_PEERS') lines
]

{ #category : #events }
LWpaP2PDevice >> recieveEvents: aBlock [
	
	eventControl attach: [ :eventString |
		| event |
		event := LWpaEvent from: eventString.
		event ifNotNil: [ aBlock value: event ] ].
]

{ #category : #'service-discovery' }
LWpaP2PDevice >> serviceAdd: aLWpaService [
	"Add a local service to service discovery"
	^ (commandControl command: ('P2P_SERVICE_ADD ', aLWpaService build)) isOk
]

{ #category : #'service-discovery' }
LWpaP2PDevice >> serviceFlush [
	^ (commandControl command: 'P2P_SERVICE_FLUSH') isOk
]

{ #category : #'service-discovery' }
LWpaP2PDevice >> serviceUpdate [
	"Updates the service counter to indicate that available services on this device have changed."
	^ (commandControl command: 'P2P_SERVICE_UPDATE') isOk
]

{ #category : #configuration }
LWpaP2PDevice >> stopConfigure [
	commandControl stopRecording.
	eventControl stopRecording.
]

{ #category : #commands }
LWpaP2PDevice >> stopFind [
	"Stops the discovery of nearby devices started by find:
	Success is indicated by the return value being true."
	^ (commandControl command: 'P2P_STOP_FIND') isOk
]

{ #category : #events }
LWpaP2PDevice >> stopRecieve [
	eventControl detach.
]
