Class {
	#name : #Device,
	#superclass : #Object,
	#instVars : [
		'name',
		'status'
	],
	#classInstVars : [
		'instances'
	],
	#category : 'IOTConnectivity-REST'
}

{ #category : #accessing }
Device class >> instances [
	^ instances ifNil: [ 
		instances := IdentitySet new ]
]

{ #category : #accessing }
Device class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: #( name status ) ]
]

{ #category : #'as yet unclassified' }
Device class >> resetInstances [
	instances := nil
]

{ #category : #accessing }
Device >> name: aString [ 
	name := aString
]

{ #category : #accessing }
Device >> status: aString [
	status := aString
]