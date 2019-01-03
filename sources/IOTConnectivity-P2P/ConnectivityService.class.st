Class {
	#name : #ConnectivityService,
	#superclass : #Object,
	#instVars : [
		'serviceDescription',
		'serviceValues',
		'device',
		'port',
		'server'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
ConnectivityService class >> new: aPortNumber [
	^ (self new) initialize: aPortNumber.
]

{ #category : #initialization }
ConnectivityService >> initialize: aPortNumber [
	serviceValues := (SmallDictionary new: 3)
	at: #identifier put: 'Pharo Device';
	at: #connection put: 'unknown';
	at: #ports put: (aPortNumber asString).
	
	serviceDescription := LWpaBonjourService new: 'ConfigurationService' as: 'connectivity.pharo._tcp' with: serviceValues.
	
	device := LWpaDevice onAnyP2P.
	port := aPortNumber.
	^ self
]

{ #category : #accessing }
ConnectivityService >> start [ 
	device configure: [
	device note: 'Setting up p2p with pharo';
	flush;
	ssidPostfix: '-pharo';
	serviceAdd: serviceDescription;
	serviceUpdate;
	listen;
	groupAdd;
	receiveEvents: [  ] ].

	server := ZnServer startDefaultOn: port.
	server delegate: IOTConnectivityAPI delegate.
	^ self
]

{ #category : #accessing }
ConnectivityService >> stop [
	device forgetConfiguration.
	server ifNotNil: [ :notNil |
		server stop.
	  server := nil ].
	^ self
]
