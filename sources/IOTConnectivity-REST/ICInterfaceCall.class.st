Class {
	#name : #ICInterfaceCall,
	#superclass : #ICCall,
	#instVars : [
		'interfaceName'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
ICInterfaceCall class >> description [
	^ 'An interface may be used to querry its log or update its configuration.'
]

{ #category : #accessing }
ICInterfaceCall class >> parameterInterfaceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'interfaceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the interface by the system.'
]

{ #category : #accessing }
ICInterfaceCall class >> path [ 
	^ '/interfaces/{interfaceName}'
]

{ #category : #accessing }
ICInterfaceCall class >> summary [
	^ 'A call to acquire an interface.'
]

{ #category : #public }
ICInterfaceCall >> get [
		response := (ICInterfaceWrapper getInterface: interfaceName) asZnResponse.
]
