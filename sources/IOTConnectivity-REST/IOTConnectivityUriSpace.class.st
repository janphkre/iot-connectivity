Class {
	#name : #IOTConnectivityUriSpace,
	#superclass : #ZnRestUriSpace,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #public }
IOTConnectivityUriSpace >> match: request [
	(IOTConnectivityCall allSubclasses reject: #isAbstract)
		do: [ :callClass |
			(callClass match: request) ifTrue: [ 
				^ callClass new ] ].
	^ nil
]
