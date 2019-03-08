Class {
	#name : #IOTConnectivityInterfaceConfigCall,
	#superclass : #IOTConnectivityCall,
	#instVars : [
		'interfaceName'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivityInterfaceConfigCall class >> description [ 
	^ 'Provides configuration capabilities for an interface.'
]

{ #category : #accessing }
IOTConnectivityInterfaceConfigCall class >> parameterInterfaceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'interfaceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the interface by the system.'
]

{ #category : #accessing }
IOTConnectivityInterfaceConfigCall class >> path [ 
	^ '/interfaces/{interfaceName}/config'
]

{ #category : #accessing }
IOTConnectivityInterfaceConfigCall class >> summary [ 
	^ 'A call to get and set the configuration of an interface.'
]

{ #category : #public }
IOTConnectivityInterfaceConfigCall >> get [
	response := (Interface instanceOrErrorFromName: interfaceName)
		ifNotNil: [:interfaceOrError |
			(interfaceOrError isKindOf: Exception)
			ifTrue: [ ZnResponse serverError: interfaceOrError messageText ]
			ifFalse: [ ZnResponse  ok: (ZnEntity 
				with: (NeoJSONWriter toString: interfaceOrError)
				type: ZnMimeType applicationJson setCharSetUTF8) ] ]
		ifNil: [ ZnResponse notFound: '/interfaces/',interfaceName asString ]
]

{ #category : #public }
IOTConnectivityInterfaceConfigCall >> put [
]
