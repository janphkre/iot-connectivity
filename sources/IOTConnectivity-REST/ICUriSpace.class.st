Class {
	#name : #ICUriSpace,
	#superclass : #ZnRestUriSpace,
	#category : #'IOTConnectivity-REST-Calls'
}

{ #category : #public }
ICUriSpace >> match: request [
	(ICCall allSubclasses reject: #isAbstract)
		do: [ :callClass |
			(callClass match: request) ifTrue: [ 
				^ callClass new ] ].
	^ nil
]
