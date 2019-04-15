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
		'groupDevice',
		'groupEventHandler',
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
ConnectivityService >> groupStarted: aString [
  self stopGroup.
  groupDevice := LWpaInterface onName: aString.
  groupDevice receiveEvents: [ :event | [ self handleGroup: event ] on: Error fork: [ :error | error pass ] ].
	groupDevice wpsPbc.
]

{ #category : #events }
ConnectivityService >> groupWpsPbc [
 ^ groupDevice wpsPbc.
]

{ #category : #events }
ConnectivityService >> handle: anEvent [
	targetEventHandler handle: anEvent.
]

{ #category : #events }
ConnectivityService >> handleGroup: anEvent [
	groupEventHandler handle: anEvent.
]

{ #category : #events }
ConnectivityService >> handleP2P: anEvent [
	p2pEventHandler handle: anEvent.
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
	
	p2pDevice := LWpaInterface onAnyP2P.
	p2pEventHandler := ConnectivityP2PEventHandler on: self.
	
	groupEventHandler := ConnectivityGroupEventHandler on: self.
	
	targetDevice := LWpaInterface onAnyNonP2P.
	targetEventHandler := TargetEventHandler on: self.
	scanSemaphore := Semaphore new.
	^ self
]

{ #category : #accessing }
ConnectivityService >> p2pDevice [
	^ p2pDevice
]

{ #category : #events }
ConnectivityService >> p2pInvite: address [
	p2pDevice p2pInvite: address.
]

{ #category : #accessing }
ConnectivityService >> start [ 
	| serverDelegate |
	self flag: 'TODO: CHECK IF THERE IS A GROUP INTERFACE ALREADY!'.
	p2pDevice configure: [
		p2pDevice note: 'Setting up p2p with pharo';
		flush;
		p2pSsidPostfix: '-pharo';
		p2pExternalServiceDiscovery: false;
		p2pDiscoverability: true;
		p2pListen;
		receiveEvents: [ :event | [ self handleP2P: event ] on: Error fork: [ :error | error pass ] ];
		p2pGroupAdd ].

	p2pDevice configureDynamic: [ 
		p2pDevice p2pServiceAdd: serviceDescription;
		p2pServiceUpdate. ].

	self flag: 'TODO: select the correct target device!'.
	self flag: 'TODO: '.
	
	targetDevice configure: [ 
		targetDevice note: 'Setting up device with pharo';
		receiveEvents: [ :event | [ self handle: event ] on: Error fork: [ :error | error pass ] ] ].
	
	serverDelegate := IOTConnectivityAPI delegate.
	
	server := ZnSingleThreadedServer startDefaultOn: port.
	server debugMode: true.
	server delegate: serverDelegate.
	
	^ self
]

{ #category : #accessing }
ConnectivityService >> stop [
	p2pDevice forgetConfiguration.
	targetDevice forgetConfiguration.
	server ifNotNil: [ :notNil |
		[ notNil closeDelegate.
			notNil stop. ]
		ensure: [ 
			server delegate: nil.
			server := nil ] ].
	p2pDevice stopReceive.
	targetDevice stopReceive.
	
	self stopGroup.
	groupDevice := nil.
	
	^ self
]

{ #category : #private }
ConnectivityService >> stopGroup [
	groupDevice isNil ifTrue: [ ^ self ]. 
	groupDevice stopReceive.
	p2pDevice p2pGroupRemove: (groupDevice interface basename).
	groupDevice := nil.
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
	serviceValues at: #connection put: 'up'.
	p2pDevice runDynamicConfig.
]
