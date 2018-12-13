Class {
	#name : #LWpaSafeFFICalloutAPI,
	#superclass : #FFICalloutAPI,
	#category : #'LibWpa-FFI-Handling'
}

{ #category : #action }
LWpaSafeFFICalloutAPI >> newBuilder [
	^ LWpaSafeFFICalloutMethodBuilder calloutAPI: self
]
