Class {
	#name : #ICNetworkScan,
	#superclass : #Object,
	#instVars : [
		'scanSemaphore',
		'libInterface'
	],
	#category : #'IOTConnectivity-REST-Data'
}

{ #category : #'instance creation' }
ICNetworkScan class >> on: aLibInterface [
  ^ (ICNetworkScan new)
    interface: aLibInterface;
    init;
    yourself.
]

{ #category : #events }
ICNetworkScan >> handleEvent: anEvent [
  (anEvent type = 'CTRL_EVENT_SCAN_RESULTS:') ifTrue: [ 
	  self scanCompleted. ]
]

{ #category : #'private-initialization' }
ICNetworkScan >> init [
  scanSemaphore := Semaphore new.
]

{ #category : #accessing }
ICNetworkScan >> interface: aLibInterface [
  libInterface isNil ifFalse: [ libInterface  stopReceive ].
  libInterface := aLibInterface.
  aLibInterface isNil ifTrue: [ ^ self ].
  aLibInterface receiveEvents: [ :event | [ self handleEvent: event ] on: Error fork: [ :error | error pass ] ]
]

{ #category : #scanning }
ICNetworkScan >> scan [
	scanSemaphore consumeAllSignals.
	libInterface scan.
	scanSemaphore wait: (Duration seconds: 15).
	^ libInterface scanResults.
]

{ #category : #events }
ICNetworkScan >> scanCompleted [
  scanSemaphore signal.
]
