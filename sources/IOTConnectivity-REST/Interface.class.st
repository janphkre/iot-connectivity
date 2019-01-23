Class {
	#name : #Interface,
	#superclass : #Object,
	#instVars : [
		'name',
		'status'
	],
	#classInstVars : [
		'instances'
	],
	#category : #'IOTConnectivity-REST-Data'
}

{ #category : #accessing }
Interface class >> forNames: nameList [
	nameList inspect.
	self flag: #TODO.
]

{ #category : #accessing }
Interface class >> instances [
	^ instances ifNil: [ 
		instances := IdentitySet new ]
]

{ #category : #accessing }
Interface class >> neoJsonMapping: mapper [
	mapper for: self do: [ :mapping |
		mapping mapInstVars: #( name status ) ]
]

{ #category : #accessing }
Interface class >> resetInstances [
	instances := nil
]

{ #category : #accessing }
Interface >> name: aString [ 
	name := aString
]

{ #category : #accessing }
Interface >> status: aString [
	status := aString
]
