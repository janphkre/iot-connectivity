Class {
	#name : #LWpaExternalObject,
	#superclass : #FFIExternalObject,
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

{ #category : #'external resource management' }
LWpaExternalObject >> autoRelease [
	"Some LGit structures need specialised free functions. Use the same autoRelease functionality
	as FFIExternalReference to achieve this.

	Note, subclasses should implement #resourceData
	and #finalizeResourceData: on class side"
	FFIExternalResourceManager addResource: self
]

{ #category : #'initialize-release' }
LWpaExternalObject >> free [
	(handle isExternalAddress and: [ handle isNull ])
		ifFalse: [ ^ self ].
	self class finalizeResourceData: handle.
	self assert: handle isNull
]

{ #category : #testing }
LWpaExternalObject >> ifNotReady: aBlock [
	"use extra block so compiler can optimize"
	self isReady ifFalse: [ aBlock value ]
]

{ #category : #testing }
LWpaExternalObject >> isExternal [
	"answer true if data referenced by receiver located in external heap, or just in object memory "
	^ handle isExternalAddress
]

{ #category : #'initialize-release' }
LWpaExternalObject >> resourceData [
	^ self getHandle
]
