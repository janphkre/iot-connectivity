Class {
	#name : #BonjourService,
	#superclass : #P2PService,
	#instVars : [
		'serviceId',
		'serviceValues'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
BonjourService class >> new: aIdString with: aDictionary [
	^ self new
  serviceId: aIdString;
	serviceValues: aDictionary;
	yourself.
]

{ #category : #building }
BonjourService >> idDump [
	"Since i was unable to find a documentation on the datagram that shall be generated here, we return the last 8 bytes that were returned in every example."
	^ (self hexDump: serviceId), '0c001001'.
]

{ #category : #building }
BonjourService >> serviceDump [
	| valuesCollection index |
	valuesCollection := Array new: (serviceValues size).
	index := 1.
	serviceValues keysAndValuesDo: [ :key :value |
		valuesCollection at: index put: (self hexDump: (key, '=', value)).
		index := index + 1 ].
	^ valuesCollection fold: [ :a :b | a, b ]
]

{ #category : #accessing }
BonjourService >> serviceId: aString [
	serviceId := aString.
]

{ #category : #accessing }
BonjourService >> serviceValues: aDictionary [
	serviceValues := aDictionary.
]

{ #category : #accessing }
BonjourService >> type [
	^ 'bonjour'
]
