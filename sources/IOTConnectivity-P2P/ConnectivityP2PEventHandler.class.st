Class {
	#name : #ConnectivityP2PEventHandler,
	#superclass : #Object,
	#instVars : [
		'service'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
ConnectivityP2PEventHandler class >> on: aService [
	^ self new service: aService.
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_PROV_DISC_PBC_REQ: anEvent [
	self flag: 'TODO: accept connections'.
]

{ #category : #events }
ConnectivityP2PEventHandler >> P2P_SERV_DISC_REQ: anEvent [
anEvent inspect.
 self flag: 'TODO: reply with P2P_SERV_DISC_RESP'
]

{ #category : #accessing }
ConnectivityP2PEventHandler >> service: aService [
	service := aService.
]
