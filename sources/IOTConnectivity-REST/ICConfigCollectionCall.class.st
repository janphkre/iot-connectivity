Class {
	#name : #ICConfigCollectionCall,
	#superclass : #ICCall,
	#instVars : [
		'interfaceName'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
ICConfigCollectionCall class >> description [ 
	^ 'Provides configuration capabilities for an interface.'
]

{ #category : #accessing }
ICConfigCollectionCall class >> httpMethods [
	^ #( get post )
]

{ #category : #accessing }
ICConfigCollectionCall class >> parameterInterfaceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'interfaceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the interface by the system.'
]

{ #category : #accessing }
ICConfigCollectionCall class >> path [ 
	^ '/interfaces/{interfaceName}/config'
]

{ #category : #accessing }
ICConfigCollectionCall class >> summary [ 
	^ 'A call to reated network configurations.'
]

{ #category : #public }
ICConfigCollectionCall >> get [
	response := (ICConfigWrapper getConfigs: interfaceName) asZnResponse.
]

{ #category : #public }
ICConfigCollectionCall >> post [
	| data config |
	data := self jsonRequest.
	data isDictionary
		ifFalse: [
			self badRequest: 'JSON map expected'.
			^ self ].
	config := ICConfig new.
	[ config ssid: (data at: #'ssid').
		config password: (data at: #'password').
	] on: KeyNotFound do: [ :error |
		self badRequest: (error messageText).
		^ self ].
	config := (ICConfigWrapper createConfig: config on: interfaceName).
	response := ZnResponse created:
		('/interfaces/{1}/config/{2}' format: { interfaceName. config networkId. })
		entity: (ZnEntity 
			with: (NeoJSONWriter toString: self)
			type: ZnMimeType applicationJson setCharSetUTF8).

]
