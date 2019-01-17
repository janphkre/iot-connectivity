Class {
	#name : #ConnectivityService,
	#superclass : #Object,
	#instVars : [
		'serviceDescription',
		'serviceValues',
		'port',
		'p2pDevice',
		'p2pEventHandler',
		'targetDevice',
		'targetEventHandler',
		'scanSemaphore',
		'server'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
ConnectivityService class >> on: aPortNumber [
	^ (self new) initialize: aPortNumber.
]

{ #category : #events }
ConnectivityService >> handle: anEvent [
	[ targetEventHandler perform: (anEvent type) with: anEvent. ]
	on: MessageNotUnderstood 
	do: [ :err | "UIManager default inform: 'Unknown Event: ', anEvent type" ]
	
]

{ #category : #events }
ConnectivityService >> handleP2P: anEvent [
	[ p2pEventHandler perform: (anEvent type) with: anEvent. ]
	on: MessageNotUnderstood 
	do: [ :err | UIManager default inform: 'Unknown P2P-Event: ', anEvent type ]
	
]

{ #category : #initialization }
ConnectivityService >> initialize: aPortNumber [
	serviceValues := (SmallDictionary new: 3)
	at: #identifier put: 'Pharo Device';
	at: #connection put: 'up';
	at: #port put: (aPortNumber asString);
	yourself.
	
	serviceDescription := LWpaBonjourService new: 'ConfigurationService' as: 'connectivity.pharo._tcp' with: serviceValues.
	port := aPortNumber.
	
	p2pDevice := LWpaDevice onAnyP2P.
	p2pEventHandler := ConnectivityP2PEventHandler on: self.
	
	targetDevice := LWpaDevice onAny.
	targetEventHandler := TargetEventHandler on: self.
	scanSemaphore := Semaphore new.
	^ self
]

{ #category : #accessing }
ConnectivityService >> p2pDevice [
	^ p2pDevice
]

{ #category : #commands }
ConnectivityService >> scan [
	scanSemaphore consumeAllSignals.
	targetDevice scan.
	scanSemaphore wait: (Duration seconds: 10).
		^ targetDevice scanResults.

]

{ #category : #events }
ConnectivityService >> scanCompleted [
	UIManager default inform: 'Scan Completed!'.
	scanSemaphore signal.
]

{ #category : #accessing }
ConnectivityService >> start [ 
	p2pDevice configure: [
	p2pDevice note: 'Setting up p2p with pharo';
	flush;
	p2pSsidPostfix: '-pharo';
	p2pServiceAdd: serviceDescription;
	p2pServiceUpdate;
	p2pListen;
	p2pGroupAdd;
	receiveEvents: [ :event | self handleP2P: event ] ].

	targetDevice configure: [ 
		targetDevice note: 'Setting up device with pharo';
		receiveEvents: [ :event | self handle: event ] ].

	server := ZnSingleThreadedServer startDefaultOn: port.
	server delegate: IOTConnectivityAPI delegate.
	^ self
]

{ #category : #accessing }
ConnectivityService >> stop [
	p2pDevice forgetConfiguration.
	targetDevice forgetConfiguration.
	server ifNotNil: [ :notNil |
		server stop.
	  server := nil ].
	p2pDevice stopReceive.
	targetDevice stopReceive.
	^ self
]

{ #category : #accessing }
ConnectivityService >> target: anInterfaceString [
	^ targetDevice interface: anInterfaceString.
]

{ #category : #accessing }
ConnectivityService >> targetDevice [
	^ targetDevice
]

{ #category : #events }
ConnectivityService >> updateStatus [
	self flag: #TODO.
	serviceValues at: #connection put: 'up'
]
