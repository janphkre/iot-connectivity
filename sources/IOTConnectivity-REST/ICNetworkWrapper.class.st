Class {
	#name : #ICNetworkWrapper,
	#superclass : #Object,
	#category : #'IOTConnectivity-REST-Wrapper'
}

{ #category : #public }
ICNetworkWrapper class >> getNetworks: interfaceName [
	| interfaceOrResponse |
	[ interfaceOrResponse :=  ICInterfaceWrapper getInterface: interfaceName.
    (interfaceOrResponse isKindOf: ZnResponse) ifTrue: [ ^ interfaceOrResponse ].
    ^ ICNetwork allInstancesOrError: interfaceOrResponse.
  ] on: Error do: [ :error | ^ ZnResponse serverError: error messageText ]
]
