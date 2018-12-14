Trait {
	#name : #TLWpaFFITrait,
	#category : #'LibWpa-Core'
}

{ #category : #resources }
TLWpaFFITrait classSide >> ffiLibrary [

	^LWpaLibrary 
]

{ #category : #'library path' }
TLWpaFFITrait classSide >> ffiLibraryName [

	^self ffiLibrary
]

{ #category : #resources }
TLWpaFFITrait >> ffiLibrary [

	^self class ffiLibrary 
]

{ #category : #resources }
TLWpaFFITrait >> ffiLibraryInstance [
	^ self class ffiLibrary uniqueInstance
]

{ #category : #resources }
TLWpaFFITrait >> ffiLibraryName [

	^self class ffiLibrary
]

{ #category : #resources }
TLWpaFFITrait >> ffiNull [

	^FFIExternalObject null
]

{ #category : #testing }
TLWpaFFITrait >> ifNotReady: aBlock [
	"use extra block so compiler can optimize"
	self isReady ifFalse: [ aBlock value ]
]
