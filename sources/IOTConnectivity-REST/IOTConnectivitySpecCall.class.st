Class {
	#name : #IOTConnectivitySpecCall,
	#superclass : #IOTConnectivityCall,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivitySpecCall class >> path [
	^ '/spec'
]

{ #category : #accessing }
IOTConnectivitySpecCall class >> summary [
	^ 'A call to get the OpenAPI specification for this server.'
]

{ #category : #public }
IOTConnectivitySpecCall >> get [
	response := ZnResponse ok:(
		ZnEntity 
			with: IOTConnectivityAPI new specString 
			type: ZnMimeType applicationJson setCharSetUTF8)
]
