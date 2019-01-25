Class {
	#name : #IOTConnectivityUriSpace,
	#superclass : #ZnRestUriSpace,
	#instVars : [
		'targetInterface'
	],
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #public }
IOTConnectivityUriSpace >> match: request [
	(IOTConnectivityCall allSubclasses reject: #isAbstract)
		do: [ :callClass |
			(callClass match: request) ifTrue: [ 
				^ (callClass new) target: targetInterface; yourself ] ].
	^ nil
]

{ #category : #accessing }
IOTConnectivityUriSpace >> target: aLWpaInterface [
	targetInterface := aLWpaInterface.
	
]
