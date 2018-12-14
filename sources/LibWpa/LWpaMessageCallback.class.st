Class {
	#name : #LWpaMessageCallback,
	#superclass : #FFICallback,
	#category : #'LibWpa-FFI-Objects'
}

{ #category : #'callback spec' }
LWpaMessageCallback class >> fnSpec [
	^#(void (String msg , FFISizeT len))
]

{ #category : #'instance creation' }
LWpaMessageCallback class >> null [
	^ self new initializeNull
]

{ #category : #'instance creation' }
LWpaMessageCallback class >> on: aBlock [
	^ self 
		signature: self fnSpec 
		block: aBlock 
]

{ #category : #initialization }
LWpaMessageCallback >> initializeNull [
	thunk := ExternalAddress null
]
