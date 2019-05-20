Class {
	#name : #TargetEventHandler,
	#superclass : #EventHandler,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
TargetEventHandler class >> on: aService [
	^ self new service: aService.
]

{ #category : #events }
TargetEventHandler >> Associated: anEvent [
	"Indicates that we are successfully associated with an AP. (Associated with ...)"
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_BSS_ADDED: anEvent [
	"A new BSS entry was added. The event prefix is followed by the BSS entry id and BSSID."
	
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_BSS_REMOVED: anEvent [
	"A BSS entry was removed. The event prefix is followed by BSS entry id and BSSID."
	
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_CONNECTED: anEvent [
	"Indicate successfully completed authentication and that the data connection is now enabled."
	service updateStatus.
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_DISCONNECTED: anEvent [
	"Disconnected, data connection is not available"
	service updateStatus.
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_REGDOM_CHANGE: anEvent [
	"Indicates that the registered domain of this interface has changed."
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_SCAN_RESULTS: anEvent [
	"New scan results available"
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_SCAN_STARTED: anEvent [
	"Started a new scan"
	UIManager default inform: 'Scan started!'.
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_SSID_REENABLED: anEvent [
	"Indicates that the temporary ban of a ssid has ended."
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_SSID_TEMP_DISABLED: anEvent [
	"Indicates that we failed to connect to a network. It was temporarly disabled because of a reoccuring error."
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_SUBNET_STATUS_UPDATE: anEvent [
	"Indicates that the status of our subnet has changed."
]

{ #category : #events }
TargetEventHandler >> Trying: anEvent [
	"Can be ignored: Log message that we are trying to assosiate with an AP. (Trying to associate with ...)"
]

{ #category : #events }
TargetEventHandler >> WPS_AP_AVAILABLE: anEvent [
	"Can be ignored."
]
