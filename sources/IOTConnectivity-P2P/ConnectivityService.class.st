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
  self stopGroupInternal.
  groupDevice := LWpaInterface onName: aString.
  groupDevice receiveEvents: [ :event | [ self handleGroup: event ] on: Error fork: [ :error | error pass ] ].
	groupDevice wpsPbc.
]

{ #category : #events }
ConnectivityService >> groupStarted: groupNetworkId on: ipAddr [
  self stopGroupInternal.
  groupDevice := LWpaInterface onName: groupNetworkId.
  groupDevice receiveEvents: [ :event | [ self handleGroup: event ] on: Error fork: [ :error | error pass ] ].
	[ self ipService: groupNetworkId. ] fork.
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

{ #category : #events }
ConnectivityService >> ipService: interfaceName [
	self ipService: interfaceName retryCount: 10.
]

{ #category : #events }
ConnectivityService >> ipService: interfaceName retryCount: retryCount [
	| status ip ipServiceValues ipServiceDescription |
	UIManager default inform: 'Creating an ip service for ', interfaceName.
	(LWpaInterface onName: interfaceName) ifNotNil: [ :interface |
		status := interface status. ] ifNil: [ 
			(Delay forMilliseconds: 500) wait.
			^ self ipService: interfaceName retryCount: (retryCount - 1) ].
	ip := (status
		at: (status findFirst: [ :item | item beginsWith: 'ip_address' ])
		ifAbsent: [ '' ]) substrings: '='.
	ip := ip size = 2
		ifTrue: [ ip second ]
		ifFalse: [ 
			(Delay forMilliseconds: 500) wait.
			^ self ipService: interfaceName retryCount: (retryCount - 1) ].
	ipServiceValues := (SmallDictionary new: 3)
	at: #ip put: ip;
	at: #port put: port;
	yourself.
	ipServiceDescription := LWpaBonjourService new: 'IPService' as: 'ip.pharo._tcp' with: ipServiceValues.
	UIManager default inform: 'Offering ', ip.
	p2pDevice p2pServiceAdd: ipServiceDescription;
	p2pServiceUpdate.
	self p2pListen.
]

{ #category : #events }
ConnectivityService >> p2pConnectPbc: peerAddress [
 p2pDevice p2pConnectPbc: peerAddress parameters: ('go_intent=0').
]

{ #category : #accessing }
ConnectivityService >> p2pDevice [
	^ p2pDevice
]

{ #category : #events }
ConnectivityService >> p2pInvite: address [
	p2pDevice p2pGroupAdd.
	p2pDevice p2pInvite: address.
]

{ #category : #events }
ConnectivityService >> p2pListen [
	p2pDevice p2pListen.
]

{ #category : #events }
ConnectivityService >> removeIpService [
	p2pDevice p2pServiceFlush;
	runDynamicConfig.
]

{ #category : #accessing }
ConnectivityService >> start [ 
	| serverDelegate |
	p2pDevice configure: [
		p2pDevice note: 'Setting up p2p with pharo';
		flush;
		p2pSsidPostfix: '-pharo';
		p2pExternalServiceDiscovery: false;
		p2pDiscoverability: true;
		p2pListen;
		receiveEvents: [ :event | [ self handleP2P: event ] on: Error fork: [ :error | error pass ] ] ].

	p2pDevice configureDynamic: [ 
		p2pDevice p2pServiceAdd: serviceDescription;
		p2pServiceUpdate. ].
	
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
	| groupInterfaceName |
	groupDevice isNil ifTrue: [ ^ self ]. 
	groupInterfaceName := (groupDevice interface basename).
	self 	stopGroupInternal.
	p2pDevice p2pGroupRemove: groupInterfaceName.
]

{ #category : #private }
ConnectivityService >> stopGroupInternal [
  groupDevice isNil ifTrue: [ ^ self ]. 
	groupDevice stopReceive.
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
