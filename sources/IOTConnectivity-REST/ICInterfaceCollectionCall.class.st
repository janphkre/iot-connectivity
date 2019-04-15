Class {
	#name : #ICInterfaceCollectionCall,
	#superclass : #ICCall,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
ICInterfaceCollectionCall class >> description [ 
	^ 'Returns a collection of available network interfaces. An interface can be used to configure its network settings and query it`s log.'
]

{ #category : #accessing }
ICInterfaceCollectionCall class >> path [ 
	^ '/interfaces'
]

{ #category : #accessing }
ICInterfaceCollectionCall class >> summary [ 
	^ 'A call to aquire a list of available network interfaces.'
]

{ #category : #public }
ICInterfaceCollectionCall >> get [
		response := ICInterfaceWrapper getInterfaces asZnResponse.
]
