Class {
	#name : #LWpaOpaqueObject,
	#superclass : #FFIOpaqueObject,
	#classVars : [
		'LibraryHandle',
		'Session'
	],
	#category : #'LibWpa-Core'
}

{ #category : #'library path' }
LWpaOpaqueObject class >> ffiLibraryName [

	^self ffiLibrary
]

{ #category : #finalization }
LWpaOpaqueObject class >> finalizeResourceData: aHandle [
	"Call the class specific free frunction if aHandle is still a valid external address."
	aHandle isNull ifTrue: [ ^self ].
	self perform: self freeFunctionSelector with: aHandle.
	aHandle beNull
]

{ #category : #'instance creation' }
LWpaOpaqueObject class >> fromHandle: aHandle [
	^self basicNew setHandle: aHandle
]

{ #category : #'initialize-release' }
LWpaOpaqueObject >> free [
	handle isExternalAddress
		ifFalse: [ ^ self ].
	self class finalizeResourceData: handle.
	self assert: handle isNull
]

{ #category : #initialization }
LWpaOpaqueObject >> initialize [
	super initialize.
	self autoRelease.
]

{ #category : #printing }
LWpaOpaqueObject >> objectPrintOn: aStream [
]

{ #category : #printing }
LWpaOpaqueObject >> printOn: aStream [
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
LWpaOpaqueObject >> shouldContinuePrintingOn: aStream [
	self ifNotReady: [ aStream nextPutAll: ' (<not initialized>)' ].
	
	^ self isReady
]
