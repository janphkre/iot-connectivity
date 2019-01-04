Class {
	#name : #LWpaEvent,
	#superclass : #Object,
	#instVars : [
		'type',
		'parameters'
	],
	#category : #'LibWpa-Commands'
}

{ #category : #'instance creation' }
LWpaEvent class >> from: aString [
	| escapingChar parameters |
	escapingChar := nil.
	parameters := aString splitOn: [ :char |
		char = (Character space) ifTrue: [ escapingChar isNil ]
		ifFalse: [
			self flag: 'TODO what is a searching literal?'.
			(char = $") | (char = $') | (char = $[) | (char = $]) ifTrue: [ 
				escapingChar ifNil: [ escapingChar := char ] ifNotNil: [
					escapingChar = char | ((escapingChar = $[) & (char = $])) ifTrue: [ escapingChar := nil ] ] ].
			false ] ].
	self flag: 'TODO allButFirst is copying stuff instead of creating a view on the underlying string.'.
	^ (self new) type: ((((parameters at: 1) allButFirst: 3) replaceAll: $- with: $_), ':') asSymbol;
	parameters: parameters;
	yourself.
	
]

{ #category : #accessing }
LWpaEvent >> parameters [
	^ parameters
]

{ #category : #accessing }
LWpaEvent >> parameters: aCollection [
	parameters := aCollection.
	^ self
]

{ #category : #accessing }
LWpaEvent >> type [
	^ type
]

{ #category : #accessing }
LWpaEvent >> type: aString [
	type := aString
]
