Class {
	#name : #ICInterfaceWrapper,
	#superclass : #Object,
	#category : #'IOTConnectivity-REST-Wrapper'
}

{ #category : #public }
ICInterfaceWrapper class >> getInterface: interfaceName [
	(ICInterface instanceOrErrorFromName: interfaceName)
		ifNotNil: [:interfaceOrError |
			(interfaceOrError isKindOf: Exception) ifTrue: [ ^ ZnResponse serverError: interfaceOrError messageText ].
			^ interfaceOrError ].
  ^ ZnResponse notFound: '/interfaces/',interfaceName asString
]

{ #category : #public }
ICInterfaceWrapper class >> getInterfaces [
  | strippedInterfaces |
  [
  (ICInterface allInstancesOrError)
		ifNotNil: [ :interfaces |
			(interfaces isEmpty)
			ifTrue: [ ^  Array braceWithNone ]
			ifFalse: [
			  strippedInterfaces := interfaces select: [ :item | (item isKindOf: Exception) = false ].
			  (strippedInterfaces isEmpty) ifTrue: [ ^ ZnResponse serverError: interfaces anyOne messageText ].
	      ^ strippedInterfaces
			] ].
	   ^ ZnResponse notFound: '/interfaces'.
	  ] on: Error do: [ :error | ZnResponse serverError: error messageText ]
]
