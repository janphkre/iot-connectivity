Class {
	#name : #TargetEventHandler,
	#superclass : #Object,
	#instVars : [
		'service'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
TargetEventHandler class >> on: aService [
	^ self new service: aService.
]

{ #category : #abstract }
TargetEventHandler >> CTRL_EVENT_CONNECTED: anEvent [
	service updateStatus.
]

{ #category : #evemts }
TargetEventHandler >> CTRL_EVENT_DISCONNECTED: anEvent [
	service updateStatus.
]

{ #category : #events }
TargetEventHandler >> CTRL_EVENT_SCAN_RESULTS: anEvent [
	service scanCompleted.
]

{ #category : #accessing }
TargetEventHandler >> service: aService [
	service := aService.
]
