Class {
	#name : #IOTConnectivityAPI,
	#superclass : #OpenAPI,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #accessing }
IOTConnectivityAPI class >> delegate [
	^ (ZnJSONRestServerDelegate new
			uriSpace: (ICUriSpace new))
]

{ #category : #accessing }
IOTConnectivityAPI class >> rootCallClass [
	^ ICCall
]

{ #category : #accessing }
IOTConnectivityAPI >> openapi [
	 ^ '3.0.2'
]
