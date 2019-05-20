Class {
	#name : #ICConfigWrapper,
	#superclass : #Object,
	#category : #'IOTConnectivity-REST-Wrapper'
}

{ #category : #public }
ICConfigWrapper class >> createConfig: configuration on: interfaceName [
  (configuration createOrErrorOn: interfaceName)
		ifNotNil: [ :networksOrError |
			(networksOrError isKindOf: Error) ifTrue: [ ^ ZnResponse serverError: networksOrError messageText ].
			^ networksOrError ].
	^ ZnResponse notFound: ('/interfaces/', interfaceName asString, '/config')
]

{ #category : #public }
ICConfigWrapper class >> getConfig: networkId on: interfaceName [
	(ICConfig allInstancesOrError: interfaceName)
		ifNotNil: [ :configsOrError |
			(configsOrError isKindOf: Error) ifTrue: [ ^ ZnResponse serverError: configsOrError messageText ].
			^ (configsOrError select: [ :item | item networkId = networkId ]) first ].
	^ ZnResponse notFound: ('/interfaces/', interfaceName asString, '/config/', networkId asString)
]

{ #category : #public }
ICConfigWrapper class >> getConfigs: interfaceName [
	(ICConfig allInstancesOrError: interfaceName)
		ifNotNil: [ :configsOrError |
			(configsOrError isKindOf: Error) ifTrue: [ ^ ZnResponse serverError: configsOrError messageText ].
			^ configsOrError ].
		^ ZnResponse notFound: ('/interfaces/', interfaceName asString, '/config')
]

{ #category : #public }
ICConfigWrapper class >> update: config on: interfaceName [
	(config updateOn: interfaceName)
		ifNotNil: [ :configOrError |
			(configOrError isKindOf: Error) ifTrue: [ ^ ZnResponse serverError: configOrError messageText ].
			^ self getConfig: (config networkId) on: interfaceName ].
		^ ZnResponse notFound: ('/interfaces/', interfaceName asString, '/config/', config networkId asString)
]
