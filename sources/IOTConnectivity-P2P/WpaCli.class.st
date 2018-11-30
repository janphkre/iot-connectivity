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
		'options',
		'interface'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #commands }
WpaCli class >> interfaces [
	"List all available interfaces"
	^ self sendCommand: 'interface'
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
  ^ self on: (interfaces first).
]

{ #category : #private }
WpaCli class >> sendCommand: aString [
	"Send a command to the wpa_cli task"
	| osProcess |
	osProcess := PipeableOSProcess waitForCommand: 'wpa_cli ', aString.
	^ osProcess exitStatus = 0
		ifTrue: [ 	osProcess output. ]
		ifFalse: [ nil ]
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

{ #category : #commands }
WpaCli >> sendCommand: aString [
	"Send a command to the wpa_cli task"
	^ WpaCli sendCommand: '-i ', self interface, ' ', aString.
]
