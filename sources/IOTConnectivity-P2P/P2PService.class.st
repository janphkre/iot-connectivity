Class {
	#name : #P2PService,
	#superclass : #Object,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #building }
P2PService >> build [ 
	^ #((self type) (self idDump) (self serviceDump ))
]

{ #category : #building }
P2PService >> idDump [
	^ SubclassResponsibility
]

{ #category : #building }
P2PService >> serviceDump [
	^ SubclassResponsibility
]

{ #category : #accessing }
P2PService >> type [ 
	^ SubclassResponsibility 
]
