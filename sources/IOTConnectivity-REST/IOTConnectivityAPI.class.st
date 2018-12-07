Class {
	#name : #IOTConnectivityAPI,
	#superclass : #OpenAPI,
	#category : 'IOTConnectivity-REST'
}

{ #category : #'as yet unclassified' }
IOTConnectivityAPI class >> rootCallClass [
	^ IOTConnectivityCall
]

{ #category : #accessing }
IOTConnectivityAPI >> openapi [
	 ^ '3.0.2'
]
