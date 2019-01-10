Class {
	#name : #ConnectivityService,
	#superclass : #Object,
	#instVars : [
		'serviceDescription',
		'serviceValues',
		'p2pDevice',
		'p2pEventHandler',
		'port',
		'server',
		'targetDevice',
		'scanSemaphore'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
ConnectivityService class >> new: aPortNumber [
	^ (self new) initialize: aPortNumber.
]

{ #category : #events }
ConnectivityService >> handle: anEvent [
	(TargetEventHandler methodNamed: (anEvent type))
	ifNotNil: [ :method | method value: anEvent. ]
	
]

{ #category : #events }
ConnectivityService >> handleP2P: anEvent [
	(ConnectivityP2PEventHandler methodNamed: (anEvent type))
	ifNotNil: [ :method | method value: anEvent. ]
	
]

{ #category : #initialization }
ConnectivityService >> initialize: aPortNumber [
	serviceValues := (SmallDictionary new: 3)
	at: #identifier put: 'Pharo Device';
	at: #connection put: 'unknown';
	at: #ports put: (aPortNumber asString).
	
	serviceDescription := LWpaBonjourService new: 'ConfigurationService' as: 'connectivity.pharo._tcp' with: serviceValues.
	port := aPortNumber.
	
	p2pDevice := LWpaDevice onAnyP2P.
	p2pEventHandler := ConnectivityP2PEventHandler on: self.
	
	scanSemaphore := Semaphore new.
	^ self
]

{ #category : #scanning }
ConnectivityService >> scan [
	scanSemaphore consumeAllSignals.
	targetDevice scan.
	scanSemaphore wait.
	^ targetDevice scanResults.
]

{ #category : #events }
ConnectivityService >> scanCompleted [
	scanSemaphore signal.
]

{ #category : #accessing }
ConnectivityService >> start [ 
	p2pDevice configure: [
	p2pDevice note: 'Setting up p2p with pharo';
	flush;
	ssidPostfix: '-pharo';
	serviceAdd: serviceDescription;
	serviceUpdate;
	listen;
	groupAdd;
	receiveEvents: [ :event | self handle: event ] ].

	server := ZnServer startDefaultOn: port.
	server delegate: IOTConnectivityAPI delegate.
	^ self
]

{ #category : #accessing }
ConnectivityService >> stop [
	p2pDevice forgetConfiguration.
	server ifNotNil: [ :notNil |
		server stop.
	  server := nil ].
	^ self
]

{ #category : #events }
ConnectivityService >> updateStatus [
	self flag: #TODO.
	serviceValues at: #connection put: 'unknown'
]
