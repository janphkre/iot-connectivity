Trait {
	#name : #TLWpaCalloutTrait,
	#category : #'LibWpa-Core'
}

{ #category : #'ffi-calls' }
TLWpaCalloutTrait >> call: fnSpec [
	<ffiCalloutTranslator>
	^ (self safeFFICalloutIn: thisContext sender)
		cdecl;
		function: fnSpec module: self ffiLibraryName
]

{ #category : #'ffi-calls' }
TLWpaCalloutTrait >> call: fnSpec options: options [
	<ffiCalloutTranslator>
	^ (self safeFFICalloutIn: thisContext sender)
		cdecl;
		options: options;
		function: fnSpec module: self ffiLibraryName
]

{ #category : #'ffi-calls' }
TLWpaCalloutTrait >> callUnchecked: fnSpec options: options [
	<ffiCalloutTranslator>
	^ (self ffiCalloutIn: thisContext sender)
		cdecl;
		options: options;
		function: fnSpec module: self ffiLibraryName
]

{ #category : #resources }
TLWpaCalloutTrait >> ffiLibrary [

	^self class ffiLibrary
]

{ #category : #'library path' }
TLWpaCalloutTrait >> ffiLibraryName [

	^self class ffiLibrary
]

{ #category : #resources }
TLWpaCalloutTrait >> ffiNull [

	^FFIExternalObject null
]

{ #category : #testing }
TLWpaCalloutTrait >> ifNotReady: aBlock [
	"use extra block so compiler can optimize"
	self isReady ifFalse: [ aBlock value ]
]

{ #category : #testing }
TLWpaCalloutTrait >> isReady [
	^ true
]

{ #category : #'ffi-calls' }
TLWpaCalloutTrait >> safeFFICalloutIn: aContext [
	^ LWpaSafeFFICalloutAPI inContext: aContext
]

{ #category : #signalling }
TLWpaCalloutTrait >> signalIfNotReady [
	self ifNotReady: [ self signalNotReady ]
]

{ #category : #signalling }
TLWpaCalloutTrait >> signalNotReady [
	LWpaObjectNotInitialized signalWith: self
]

{ #category : #'argument validation' }
TLWpaCalloutTrait >> validate: anObject shouldBe: aClass [
	self class validate: anObject shouldBe: aClass

]

{ #category : #enumerating }
TLWpaCalloutTrait >> withReturnHandlerDo: callBlock [
	^ callBlock value handleLWpaReturnCode
]
