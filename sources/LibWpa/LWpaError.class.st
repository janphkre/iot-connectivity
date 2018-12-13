Class {
	#name : #LWpaError,
	#superclass : #Error,
	#instVars : [
		'object'
	],
	#category : #'LibWpa-Core'
}

{ #category : #signalling }
LWpaError class >> signalWith: anObject [
	^ self new
		object: anObject;
		signal
]

{ #category : #initialization }
LWpaError >> initialize [
	super initialize.
	"self messageText: LGitError lastMessage"
]

{ #category : #accessing }
LWpaError >> object [
	^ object
]

{ #category : #accessing }
LWpaError >> object: anObject [
	object := anObject
]
