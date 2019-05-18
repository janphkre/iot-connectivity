Class {
	#name : #ICNetworkWrapper,
	#superclass : #Object,
	#category : #'IOTConnectivity-REST-Wrapper'
}

{ #category : #public }
ICNetworkWrapper class >> getNetworks: interfaceName [
	[ ^ ICNetwork allInstancesOrError: interfaceName.
  ] on: Error do: [ :error | ^ ZnResponse serverError: error messageText ]
]
