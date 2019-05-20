Class {
	#name : #ICData,
	#superclass : #Object,
	#category : #'IOTConnectivity-REST-Data'
}

{ #category : #'instance creation' }
ICData class >> allInstancesOrError [
	^ ([(self dataCollection) collect: [ :anItem | self instanceOrError: anItem ]
		] on: Error do: [ :error | ^ error ]) value
]

{ #category : #public }
ICData class >> allInstancesOrError: interfaceName [
  | libInterface |
  ([ libInterface := LWpaInterface onName: interfaceName.
		^ (self dataCollection: libInterface) collect: [ :anItem | self instanceOrError: anItem ]
  ] on: Error do: [ :error | ^ error ]) value
]

{ #category : #accessing }
ICData class >> dataCollection [
	^ SubclassResponsibility 
]

{ #category : #public }
ICData class >> dataCollection: aLibInterface [
	^ SubclassResponsibility 
]

{ #category : #accessing }
ICData class >> instance: anItem [
	^ SubclassResponsibility
]

{ #category : #'instance creation' }
ICData class >> instanceOrError: anItem [
  ^ ([ self instance: anItem ] on: Error do: [ :error | error ]) value
]

{ #category : #testing }
ICData class >> isAbstract [
	^ self = ICData
]

{ #category : #parsing }
ICData class >> parseFlags: aString [
	| result |
	result := Set new.
	(aString splitOn: $[) do: [ :item |
		item isEmpty ifFalse: [ result add: (item allButLast asSymbol) ] ].
	^ result
]
