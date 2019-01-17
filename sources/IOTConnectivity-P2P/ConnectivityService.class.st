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
	#classInstVars : [
		'instance'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #accessing }
ConnectivityService class >> managedInstance [ 
	^ instance.
]

{ #category : #'instance creation' }
ConnectivityService class >> on: aPortNumber [
	^ instance
]

{ #category : #'instance creation' }
ConnectivityService class >> onDefault: aPortNumber [
	instance ifNotNil: [ instance stop. ].
	instance := (self new) initialize: aPortNumber.
	^ instance
]

{ #category : #events }
ConnectivityService >> handle: anEvent [
	[ targetEventHandler perform: (anEvent type) with: anEvent. ]
	on: MessageNotUnderstood 
	do: [ :err | 
		(err receiver = targetEventHandler) ifTrue: [
			UIManager default inform: 'Unknown Event: ', anEvent type.
			^ self ].
		err pass. ]
]

{ #category : #events }
ConnectivityService >> handleP2P: anEvent [
	[ p2pEventHandler perform: (anEvent type) with: anEvent. ]
	on: MessageNotUnderstood 
	do: [ :err | 
		(err receiver = p2pEventHandler) ifTrue: [
			UIManager default inform: 'Unknown P2P-Event: ', anEvent type.
			^ self ].
		err pass. ]
	
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
	scanSemaphore wait: (Duration seconds: 15).
		^ targetDevice scanResults.

]

{ #category : #events }
ConnectivityService >> scanCompleted [
	UIManager default inform: 'Scan Completed!'.
	scanSemaphore signal.
]

{ #category : #accessing }
ConnectivityService >> start [ 
	| serverDelegate |
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

	serverDelegate := IOTConnectivityAPI delegate.
	serverDelegate uriSpace target: targetDevice.
	
	server := ZnSingleThreadedServer startDefaultOn: port.
	server delegate: serverDelegate.
	
	^ self
]

{ #category : #accessing }
ConnectivityService >> stop [
	p2pDevice forgetConfiguration.
	targetDevice forgetConfiguration.
	server ifNotNil: [ :notNil |
		[ server stop. ]
		ensure: [ server := nil ] ].
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
