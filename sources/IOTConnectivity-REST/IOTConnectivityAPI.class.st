Class {
	#name : #IOTConnectivityAPI,
	#superclass : #OpenAPI,
	#category : 'IOTConnectivity-REST'
}

{ #category : #accessing }
IOTConnectivityAPI class >> delegate [
	^ (ZnRestServerDelegate new
			uriSpace: (IOTConnectivityUriSpace new))
]

{ #category : #accessing }
IOTConnectivityAPI class >> rootCallClass [
	^ IOTConnectivityCall
]

{ #category : #accessing }
IOTConnectivityAPI >> openapi [
	 ^ '3.0.2'
]
