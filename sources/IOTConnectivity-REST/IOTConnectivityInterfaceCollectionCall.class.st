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
	interfaceNameList := targetDevice interfacesNonP2P.
	self flag: 'TODO: ERRORHANDLING'.
	Interface forNames: interfaceNameList.
	response := ZnResponse ok: (ZnEntity 
		with: (NeoJSONWriter toString: Interface instances)
		type: ZnMimeType  applicationJson setCharSetUTF8).
]
