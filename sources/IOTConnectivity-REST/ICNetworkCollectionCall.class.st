Class {
	#name : #ICNetworkCollectionCall,
	#superclass : #ICCall,
	#instVars : [
		'interfaceName'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
ICNetworkCollectionCall class >> description [ 
	^ 'Returns a collection of available networks for a given network interface.'
]

{ #category : #accessing }
ICNetworkCollectionCall class >> parameterInterfaceName [
	<openApiParameter: #( common )>
	^ OAParameter new
		name: 'interfaceName';
		in: #path;
		beString;
		required: true;
		description: 'The name given to the interface by the system.'
]

{ #category : #accessing }
ICNetworkCollectionCall class >> path [ 
	^ '/interfaces/{interfaceName}/networks'
]

{ #category : #accessing }
ICNetworkCollectionCall class >> summary [ 
	^ 'A call to get available networks of an interface.'
]

{ #category : #public }
ICNetworkCollectionCall >> get [
  response := (ICNetworkWrapper getNetworks: interfaceName) asZnResponse.
]
