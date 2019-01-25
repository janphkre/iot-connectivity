Class {
	#name : #IOTConnectivityInterfaceCollectionCall,
	#superclass : #IOTConnectivityCall,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivityInterfaceCollectionCall class >> description [ 
	^ 'Returns a collection of available network interfaces. An interface can be used to configure its network settings and query it`s log.'
]

{ #category : #accessing }
IOTConnectivityInterfaceCollectionCall class >> path [ 
	^ '/interfaces'
]

{ #category : #accessing }
IOTConnectivityInterfaceCollectionCall class >> summary [ 
	^ 'A call to aquire a list of available network interfaces.'
]

{ #category : #public }
IOTConnectivityInterfaceCollectionCall >> get [
	| interfaceNameList |
	interfaceNameList := targetInterface interfacesNonP2P.
	self flag: 'TODO ERROR HANDLING OF INTERFACE FORNAMES: …'.
	response := ZnResponse ok: (ZnEntity 
		with: (NeoJSONWriter toString: (Interface forNames: interfaceNameList))
		type: ZnMimeType  applicationJson setCharSetUTF8).
]
