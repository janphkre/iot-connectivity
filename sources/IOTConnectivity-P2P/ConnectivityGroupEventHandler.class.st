Class {
	#name : #ConnectivityGroupEventHandler,
	#superclass : #EventHandler,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
ConnectivityGroupEventHandler class >> on: aService [
	^ self new service: aService.
]

{ #category : #events }
ConnectivityGroupEventHandler >> WPS_TIMEOUT: anEvent [
 service groupWpsPbc.
]
