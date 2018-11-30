Class {
	#name : #WpaCli,
	#superclass : #Object,
	#instVars : [
		'options',
		'interface'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #accessing }
WpaCli >> interface [
	"Return the interface which will be used to listen on"
	^ interface
]

{ #category : #accessing }
WpaCli >> interface: aString [
	"Set the name of the interface that shall be used for this WpaCli"
	interface := aString
]

{ #category : #commands }
WpaCli >> interfaces [
	"List all available interfaces"
	^ self sendCommand: 'interface'
]

{ #category : #private }
WpaCli >> sendCommand: aString [
	"Send a command to the wpa_cli task"
	
]
