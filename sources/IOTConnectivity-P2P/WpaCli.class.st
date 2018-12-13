"
Similar to wpa_cli(8) i am an interface to the wpasupplicant.

I work by sending commands to wpa_cli and returning their result.
e.g.
  wpaCli := WpaCli new.
  availableInterfaces := interfaces.
	wpaCli interface: (availableInterfaces first).
	wpaCli sendCommand: 'p2p_find'.


"
Class {
	#name : #WpaCli,
	#superclass : #Object,
	#instVars : [
		'interface'
	],
	#category : #'IOTConnectivity-P2P-FFI-Access'
}

{ #category : #private }
WpaCli class >> command: aString [
	"Send a command to the wpa_cli task"
	| osProcess |
	osProcess := PipeableOSProcess waitForCommand: 'wpa_cli ', aString.
	^ osProcess succeeded
		ifTrue: [ 	osProcess output ]
		ifFalse: [ nil ]
]

{ #category : #commands }
WpaCli class >> interfaces [
	"List all available interfaces.
	We skip the first two lines because they contain 'Selected interface abc' and 'Available interfaces:'. "
	^ (self command: 'interface') lines allButFirst: 2.
	
]

{ #category : #'instance creation' }
WpaCli class >> on: aString [
	| instance |
	instance := self new.
	instance interface: aString.
	^ instance.

]

{ #category : #'instance creation' }
WpaCli class >> onAny [
	| interfaces |
	interfaces := self interfaces.
  ^ self on: (interfaces at: 1).
]

{ #category : #commands }
WpaCli >> command: aString [
	"Send a command to the wpa_cli task"
	^ WpaCli command: '-i ', self interface, ' ', aString.
]

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
