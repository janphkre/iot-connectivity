Class {
	#name : #ICConfigCall,
	#superclass : #ICCall,
	#instVars : [
		'interfaceName',
		'networkId'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
ICConfigCall class >> description [ 
	^ 'Allows a configuration to be selected for connection. Also by passing in new settings the configuration will be altered.'
]

{ #category : #accessing }
ICConfigCall class >> httpMethods [
	^ #( put get )
]

{ #category : #accessing }
ICConfigCall class >> parameterInterfaceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'interfaceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the interface by the system.'
]

{ #category : #accessing }
ICConfigCall class >> parameterNetworkId [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'networkId';
		in: #path;
		beString;
		required: true;
		description: 'The networkId assigned to the configuration by the system.'
]

{ #category : #accessing }
ICConfigCall class >> path [ 
	^ '/interfaces/{interfaceName}/config/{networkId}'
]

{ #category : #accessing }
ICConfigCall class >> summary [ 
	^ 'A call to connect to and reconfigure a configured network.'
]

{ #category : #public }
ICConfigCall >> get [
	response := (ICConfigWrapper getConfig: networkId on: interfaceName) asZnResponse.
]

{ #category : #public }
ICConfigCall >> put [
	| data config |
	[ data := self jsonRequest. ] on: Error do: [
		self badRequest: 'JSON expected'.
		^ self ].
	data isDictionary
		ifFalse: [
			self badRequest: 'JSON map expected'.
			^ self ].
	data isEmpty
		ifTrue: [ 
			self badRequest: 'No change provided!'.
			^ self ].
	config := ICConfig new.
	config networkId: networkId.
	(data at: #'ssid' ifAbsent: nil)
		ifNotNil: [ :result | 
			config ssid: result.
			config password: ''. ].
	(data at: #'password' ifAbsent: nil)
		ifNotNil: [ :result | config password: result. ].
	config disabled: (data at: #'disabled' ifAbsent: nil).
	config selected: (data at: #'selected' ifAbsent: nil).
	response := (ICConfigWrapper update: config on: interfaceName) asZnResponse.
]
