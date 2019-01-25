Class {
	#name : #IOTConnectivityInterfaceCall,
	#superclass : #IOTConnectivityCall,
	#instVars : [
		'interfaceName'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivityInterfaceCall class >> description [
	^ 'An interface may be used to querry its log or update its configuration.'
]

{ #category : #accessing }
IOTConnectivityInterfaceCall class >> parameterInterfaceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'interfaceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the interface by the system.'
]

{ #category : #accessing }
IOTConnectivityInterfaceCall class >> path [ 
	^ '/interfaces/{interfaceName}'
]

{ #category : #accessing }
IOTConnectivityInterfaceCall class >> summary [
	^ 'A call to acquire an interface.'
]

{ #category : #accessing }
IOTConnectivityInterfaceCall >> get [
	response := (Interface instanceOrError: interfaceName)
		ifNotNil: [:interface |
			self flag: 'TODO: check if "interface" is an error!'.
			ZnResponse  ok: (ZnEntity 
				with: (NeoJSONWriter toString: interface)
				type: ZnMimeType applicationJson setCharSetUTF8) ]
		ifNil: [ ZnResponse notFound: '/interfaces/',interfaceName asString ]
]
