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
TargetEventHandler >> CTRL_EVENT_SCAN_RESULTS: anEvent [
	"New scan results available"
	service scanCompleted.
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_SCAN_STARTED: anEvent [
	"Started a new scan"
	UIManager default inform: 'Scan started!'.
]
