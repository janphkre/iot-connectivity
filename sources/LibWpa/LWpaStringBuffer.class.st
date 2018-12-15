Class {
	#name : #LWpaStringBuffer,
	#superclass : #FFIExternalObject,
	#instVars : [
		'bufferSize'
	],
	#category : #'LibWpa-FFI-Objects'
}

{ #category : #'instance creation' }
LWpaStringBuffer class >> new: size [
	^ self basicNew initialize: size
]

{ #category : #converting }
LWpaStringBuffer >> asString: length [
	| data |
	data := ExternalData 
		fromHandle: handle 
		type: ExternalType string.
	data isNull ifTrue: [ ^ nil ].
	^ data fromCString: length
]

{ #category : #'initialize-release' }
LWpaStringBuffer >> free [
	handle isExternalAddress
		ifFalse: [ ^ self ].
	self class finalizeResourceData: handle.
	self assert: handle isNull
]

{ #category : #initialization }
LWpaStringBuffer >> initialize: size [
	bufferSize := size.
	self setHandle: (ExternalAddress allocate: (FFICharacterType externalTypeSize * size)).
	self autoRelease.
]

{ #category : #accessing }
LWpaStringBuffer >> size [
	^ bufferSize.
]
