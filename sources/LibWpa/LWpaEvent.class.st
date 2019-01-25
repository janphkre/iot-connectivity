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
			( { $". $'. $[. $]. } includes: char) ifTrue: [ 
				escapingChar ifNil: [ escapingChar := char ] ifNotNil: [
					(escapingChar = char or: [(escapingChar = $[) and: [ (char = $]) ] ] ) ifTrue: [ escapingChar := nil ] ] ].
			false ] ].
	^ (self new) type: ((((parameters at: 1) allButFirst: 3) replaceAll: $- with: $_), ':') asSymbol;
	parameters: parameters;
	yourself.
	
]

{ #category : #accessing }
LWpaEvent >> parameter: index [
	^ parameters at: index
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
