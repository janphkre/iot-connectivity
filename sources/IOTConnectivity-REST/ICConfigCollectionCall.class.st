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
	^ 'A call to get and set the configuration of an interface.'
]

{ #category : #public }
ICConfigCollectionCall >> get [
   self flag: #TODO.
		response := (ICInterfaceWrapper getInterface: interfaceName) asZnResponse.
]
