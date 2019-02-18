Class {
	#name : #EventHandler,
	#superclass : #Object,
	#instVars : [
		'service'
	],
	#category : #'IOTConnectivity-P2P'
}

{ #category : #events }
EventHandler >> handle: anEvent [
	[ self perform: (anEvent type) with: anEvent. ]
	on: MessageNotUnderstood 
	do: [ :err | 
		(err receiver = self) ifTrue: [
			UIManager default inform: 'Unknown Event: ', anEvent type.
			^ self ].
		err pass. ]
]

{ #category : #accessing }
EventHandler >> service: aService [
	service := aService.
]
