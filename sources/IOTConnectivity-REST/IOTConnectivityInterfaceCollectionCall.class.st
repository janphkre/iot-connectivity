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
  | strippedInterfaces |
  response := (Interface allInstancesOrError)
		ifNotNil: [ :interfaces |
			(interfaces isEmpty)
			ifTrue: [ ZnResponse notFound: '/interfaces' ]
			ifFalse: [
			  strippedInterfaces := interfaces select: [ :item | (item isKindOf: Exception) = false ].
			  (strippedInterfaces isEmpty)
	         ifTrue: [ ZnResponse serverError: interfaces anyOne messageText ]
	         ifFalse: [ ZnResponse  ok: (ZnEntity 
				  with: (NeoJSONWriter toString: strippedInterfaces)
				  type: ZnMimeType applicationJson setCharSetUTF8) ] ] ]
		ifNil: [ ZnResponse notFound: '/interfaces' ]
]
