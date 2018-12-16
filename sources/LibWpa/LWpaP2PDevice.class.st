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

{ #category : #validation }
LWpaP2PDevice >> check: aString [
	^ aString beginsWith: 'OK'
]

{ #category : #accessing }
LWpaP2PDevice >> commandControl [
	^ commandControl
]

{ #category : #accessing }
LWpaP2PDevice >> commandControl: aLWpaControl [
	commandControl := aLWpaControl
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
LWpaP2PDevice >> find: aBlock [
	"Finds nearby devices as possible peers.
	This is a async call and the given block will return all findings.
	Success is indicated by the return value being true."
	self flag: 'TODO: register aBlock as a callback of scan results'.
	^ self check: (commandControl command: 'P2P_FIND')
]

{ #category : #commands }
LWpaP2PDevice >> flush [ 
	"Flushes the configuration for the interface.
	If this returns false you may want to use another interface."
  ^ self check: (commandControl command: 'p2p_flush')
]

{ #category : #commands }
LWpaP2PDevice >> peers [
	"Gives an array of possible peers found through find:"
	^ (commandControl command: 'p2p_peers') lines
]

{ #category : #'service-discovery' }
LWpaP2PDevice >> serviceAdd: aLWpaService [
	"Add a local service to service discovery"
	^ self check: (commandControl command: ('P2P_SERVICE_ADD ', aLWpaService build))
]

{ #category : #'service-discovery' }
LWpaP2PDevice >> serviceFlush [
	^ self check: (commandControl command: 'P2P_SERVICE_FLUSH')
]

{ #category : #'service-discovery' }
LWpaP2PDevice >> serviceUpdate [
	"Updates the service counter to indicate that available services on this device have changed."
	^ self check: (commandControl command: 'P2P_SERVICE_UPDATE')
]

{ #category : #commands }
LWpaP2PDevice >> stopFind [
	"Stops the discovery of nearby devices started by find:
	Success is indicated by the return value being true."
	^ self check: (commandControl command: 'P2P_STOP_FIND')
]
