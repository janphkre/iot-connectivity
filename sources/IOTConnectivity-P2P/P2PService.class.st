Class {
	#name : #P2PService,
	#superclass : #Object,
	#classInstVars : [
		'svmPacket'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #initialization }
P2PService class >> reset [ 
	svmPacket := nil
]

{ #category : #accessing }
P2PService class >> svmPacket [
	^ svmPacket ifNil: [ 
		 svmPacket := SmallDictionary newFromPairs: #(
		'_tcp.local.' 'c00c' 
		'local.' 'c011' 
		'_udp.local.' 'c01c').
		svmPacket. ].
]

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
	aString size > 255
		ifTrue: [ HexTooBigError signal: 'The string is too big to form a hexdump from it!' ].
		^ String new: aString size * 2 + 2
			streamContents: [ :stream |
				stream nextPutAll: (aString size printStringBase: 16 length: 2 padded: true).
				aString do: [ :ch | stream nextPutAll: (ch asInteger printStringBase: 16 length: 2 padded: true) ] ]
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
