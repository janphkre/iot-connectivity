Class {
	#name : #LWpaExternalStructure,
	#superclass : #FFIExternalStructure,
	#traits : 'TLWpaCalloutTrait',
	#classTraits : 'TLWpaCalloutTrait classTrait',
	#category : #'LibWpa-Core'
}

{ #category : #'external resource management' }
LWpaExternalStructure >> autoRelease [
	"Some LGit structures need specialised free functions. Use the same autoRelease functionality
	as FFIExternalReference to achieve this.

	Note, subclasses should implement #resourceData
	and #finalizeResourceData: on class side"
	FFIExternalResourceManager addResource: self
]

{ #category : #'initialize-release' }
LWpaExternalStructure >> free [
	(handle isExternalAddress and: [ handle isNull ])
		ifFalse: [ ^ self ].
	self class finalizeResourceData: handle.
	self assert: handle isNull
]

{ #category : #testing }
LWpaExternalStructure >> ifNotReady: aBlock [
	"use extra block so compiler can optimize"
	self isReady ifFalse: [ aBlock value ]
]

{ #category : #testing }
LWpaExternalStructure >> isExternal [
	"answer true if data referenced by receiver located in external heap, or just in object memory "
	^ handle isExternalAddress
]

{ #category : #'initialize-release' }
LWpaExternalStructure >> resourceData [
	^ self getHandle
]
