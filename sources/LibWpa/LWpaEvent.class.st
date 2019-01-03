Class {
	#name : #LWpaEvent,
	#superclass : #Object,
	#instVars : [
		'type'
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
			(char = $") | (char = $') ifTrue: [ 
				escapingChar ifNil: [ escapingChar := char ] ifNotNil: [
					escapingChar = char ifTrue: [ escapingChar := nil ] ] ].
			false ] ].
	
	^ (self new) type: (parameters at: 1) asSymbol;
	parameters: parameters;
	yourself.
	
]

{ #category : #accessing }
LWpaEvent >> type [
	^ type
]

{ #category : #accessing }
LWpaEvent >> type: aString [
	type := aString
]
