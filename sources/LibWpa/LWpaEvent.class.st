Class {
	#name : #LWpaEvent,
	#superclass : #Object,
	#instVars : [
		'string'
	],
	#category : #'LibWpa-Commands'
}

{ #category : #'instance creation' }
LWpaEvent class >> from: aString [
	^ self new string: aString.
	
]

{ #category : #accessing }
LWpaEvent >> string [
	^ string
]

{ #category : #accessing }
LWpaEvent >> string: aString [
	string := aString
]
