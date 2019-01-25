Class {
	#name : #LWpaP2PService,
	#superclass : #Object,
	#classInstVars : [
		'svmPacket'
	],
	#category : #'LibWpa-Commands'
}

{ #category : #initialization }
LWpaP2PService class >> reset [ 
	svmPacket := nil
]

{ #category : #accessing }
LWpaP2PService class >> svmPacket [
	^ svmPacket ifNil: [ 
		 svmPacket := SmallDictionary newFromPairs: #(
		'_tcp.local.' 'c00c' 
		'local.' 'c011' 
		'_udp.local.' 'c01c').
		svmPacket. ].
]

{ #category : #building }
LWpaP2PService >> build [
	^ self type, ' ', self idDump, ' ', self serviceDump.
]

{ #category : #building }
LWpaP2PService >> buildResponse [
	"Service discovery has the following header: Length(2b), Type(1b) TransmissionId(1b), Status(1b), vendor specific(variable)."
	| responseValue |
	self flag: 'TODO build correct header!'.
	responseValue :=	(self idDump), (self serviceDump).
	^ (self responseType), (responseValue size printStringBase: 16 length: 4 padded: true), responseValue.
	
]

{ #category : #private }
LWpaP2PService >> hexDump: aString [
	"Hexdumps a string without 16r prefixing.
	This hexdump adds the string length as 2bytes in front of this.
	Keep in mind that this means no more than 255 characters.
	A exception is raised otherwise by this method."
	aString size > 255
		ifTrue: [ LWpaHexTooBigError signal: 'The string is too big to form a hexdump from it!' ].
		^ String new: aString size * 2 + 2
			streamContents: [ :stream |
				stream nextPutAll: (aString size printStringBase: 16 length: 2 padded: true).
				aString do: [ :ch | stream nextPutAll: (ch asInteger printStringBase: 16 length: 2 padded: true) ] ]
]

{ #category : #building }
LWpaP2PService >> idDump [
	^ SubclassResponsibility
]

{ #category : #building }
LWpaP2PService >> responseType [ 
	^ SubclassResponsibility 
]

{ #category : #building }
LWpaP2PService >> serviceDump [
	^ SubclassResponsibility
]

{ #category : #building }
LWpaP2PService >> type [ 
	^ SubclassResponsibility 
]
