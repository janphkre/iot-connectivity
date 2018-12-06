Class {
	#name : #P2PService,
	#superclass : #Object,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #building }
P2PService >> build [
	^ self type, ' ', self idDump, ' ', self serviceDump.
]

{ #category : #building }
P2PService >> hexDump: aString [
	"Hexdumps a string without 16r prefixing.
	This hexdump adds the string length as 2bytes in front of this.
	Keep in mind that this means no more than 255 characters.
	A exception is raised otherwise by this method."
	aString size <= 255
		ifTrue: [ 
			^ String new: aString size * 2 + 2
			streamContents: [ :stream |
				stream nextPutAll: (aString size printStringHex).
				aString do: [ :ch | stream nextPutAll: ch printStringHex ] ] ]
		ifFalse: [ HexTooBigException signal: 'The string is too big to form a hexdump from it!' ].
]

{ #category : #building }
P2PService >> idDump [
	^ SubclassResponsibility
]

{ #category : #building }
P2PService >> serviceDump [
	^ SubclassResponsibility
]

{ #category : #accessing }
P2PService >> type [ 
	^ SubclassResponsibility 
]
