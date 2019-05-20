Class {
	#name : #ICNetworkWrapper,
	#superclass : #Object,
	#category : #'IOTConnectivity-REST-Wrapper'
}

{ #category : #public }
ICNetworkWrapper class >> getNetworks: interfaceName [
  (ICNetwork allInstancesOrError: interfaceName)
		ifNotNil: [ :networksOrError |
			(networksOrError isKindOf: Error) ifTrue: [ ^ ZnResponse serverError: networksOrError messageText ].
			^ networksOrError ].
	^ ZnResponse notFound: ('/interfaces/', interfaceName asString, '/networks')
]
