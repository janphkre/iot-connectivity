Class {
	#name : #LWpaExternalObject,
	#superclass : #FFIExternalObject,
	#traits : 'TLWpaCalloutTrait',
	#classTraits : 'TLWpaCalloutTrait classTrait',
	#classVars : [
		'LibraryHandle',
		'Session'
	],
	#category : #'LibWpa-Core'
}

{ #category : #'library path' }
LWpaExternalObject class >> ffiLibraryName [

	^self ffiLibrary
]

{ #category : #finalization }
LWpaExternalObject class >> finalizeResourceData: aHandle [
	"Call the class specific free frunction if aHandle is still a valid external address."
	aHandle isNull ifTrue: [ ^self ].
	self perform: self freeFunctionSelector with: aHandle.
	aHandle beNull
]

{ #category : #'instance creation' }
LWpaExternalObject class >> fromHandle: aHandle [
	^self basicNew setHandle: aHandle
]

{ #category : #'initialize-release' }
LWpaExternalObject >> free [
	handle isExternalAddress
		ifFalse: [ ^ self ].
	self class finalizeResourceData: handle.
	self assert: handle isNull
]

{ #category : #initialization }
LWpaExternalObject >> initialize [
	super initialize.
	self autoRelease.
]

{ #category : #printing }
LWpaExternalObject >> objectPrintOn: aStream [
]

{ #category : #printing }
LWpaExternalObject >> printOn: aStream [
	| title |
	title := self class name.
	aStream
		nextPutAll: (title first isVowel ifTrue: [ 'an ' ] ifFalse: [ 'a ' ]);
		nextPutAll: title.
		
	(self shouldContinuePrintingOn: aStream) ifFalse: [ ^ self ].
	
	aStream nextPutAll: ' ('.
	self objectPrintOn: aStream.
	aStream nextPut: $)
]

{ #category : #asserting }
LWpaExternalObject >> shouldContinuePrintingOn: aStream [
	self ifNotReady: [ aStream nextPutAll: ' (<not initialized>)' ].
	
	^ self isReady
]
