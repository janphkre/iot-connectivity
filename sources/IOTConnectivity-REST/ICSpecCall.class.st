Class {
	#name : #ICSpecCall,
	#superclass : #ICCall,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
ICSpecCall class >> path [
	^ '/spec'
]

{ #category : #accessing }
ICSpecCall class >> summary [
	^ 'A call to get the OpenAPI specification for this server.'
]

{ #category : #public }
ICSpecCall >> get [
	response := ZnResponse ok:(
		ZnEntity 
			with: IOTConnectivityAPI new specString 
			type: ZnMimeType applicationJson setCharSetUTF8)
]
