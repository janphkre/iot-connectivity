Class {
	#name : #LWpaReadWriteSizeT,
	#superclass : #FFIExternalValueHolder,
	#category : #'LibWpa-FFI-Objects'
}

{ #category : #'instance creation' }
LWpaReadWriteSizeT class >> new: value [
	^ self basicNew initialize: value
]

{ #category : #accessing }
LWpaReadWriteSizeT class >> typeDecl [
	^ 'size_t'
]

{ #category : #initialization }
LWpaReadWriteSizeT >> initialize: value [
	self initialize.
	self value: value
]
