"
This library is meant to provide the functionality of the wpa_supplicant control interface to pharo.
https://w1.fi/wpa_supplicant/devel/ctrl_iface_page.html

The used library-module consists of 2 files: wpa_ctrl.c and wpa_ctrl.h

After cloning the repository with:

git clone git://w1.fi/srv/git/hostap.git

Since this library only exists for unix it does not make sense to use me on other systems as well.
Run this shell script to compile for unix:
#!/bin/sh
cd ""$( dirname ""${BASH_SOURCE[0]}"" )""
make -C ./hostap/src/ clean
rm ./*.o
rm ./*.so
gcc -c -Wall -Werror -fpic ./hostap/src/common/wpa_ctrl.c ./hostap/src/utils/common.c -I ./hostap/src/utils/ -I ./hostap/src
gcc -shared -o libwpa.so ./wpa_ctrl.o ./common.o
"
Class {
	#name : #LWpaLibrary,
	#superclass : #FFILibrary,
	#instVars : [
		'initialized',
		'commandHandle',
		'eventHandle'
	],
	#category : #'LibWpa-FFI-Handling'
}

{ #category : #'class initialization' }
LWpaLibrary class >> initialize [
	"Required to reset the Initialized flag on image startup.
	Force libgit initialization since we just installed libgit.
	Otherwise this would cause a libgit crash"
	
	Smalltalk addToStartUpList: self.
	self uniqueInstance initializeLibWpa
]

{ #category : #'system startup' }
LWpaLibrary class >> shutDown: quitting [

	quitting ifFalse: [ ^ self ].
	self uniqueInstance shutdownLibWpa.
]

{ #category : #'system startup' }
LWpaLibrary class >> startUp: isImageStarting [

	isImageStarting ifTrue: [ self uniqueInstance initializeLibWpa ]
]

{ #category : #private }
LWpaLibrary >> closeHandles [
	self doSafe: [ self libwpa_close: commandHandle ].
	commandHandle := nil.
	self doSafe: [ self libwpa_detach: eventHandle ].
	self doSafe: [ self libwpa_close: eventHandle ].
	eventHandle := nil.
]

{ #category : #private }
LWpaLibrary >> doSafe: aBlock [
	aBlock
	onError: Error
	do: [ :ex | ]
]

{ #category : #operations }
LWpaLibrary >> forgetInitializationState [

	initialized := nil.
]

{ #category : #operations }
LWpaLibrary >> initializeLibWpa [
	[	commandHandle := self libwpa_open.
		eventHandle := self libwpa_open.
		self libwpa_attach: eventHandle.
		self recordInitializationSuccess ]
		on: Error
		do: [ :ex |
			self closeHandles.
			self recordInitializationFailure.
			ex pass ]
]

{ #category : #testing }
LWpaLibrary >> isInitialized [

	^initialized == true
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_attach: aControlHandle [
	^ self ffiCall: #(int  wpa_ctrl_attach(LWpaControlHandle *ctrl))
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_close: control [
	^ self ffiCall: #(void  wpa_ctrl_close(LWpaControlHandle *control))
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_detach: aControlHandle [
	^ self ffiCall: #(int  wpa_ctrl_attach(LWpaControlHandle *ctrl))
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_open [
	^ self ffiCall: #(LWpaControlHandle  *wpa_ctrl_open(String ctrl_path))
]

{ #category : #'accessing platform' }
LWpaLibrary >> macModuleName [ 
	self error: 'Module not found.'
]

{ #category : #operations }
LWpaLibrary >> recordInitializationFailure [

	initialized := false
]

{ #category : #operations }
LWpaLibrary >> recordInitializationSuccess [

	initialized ifNil: [initialized := true]
]

{ #category : #operations }
LWpaLibrary >> shutdownLibWpa [
	[ self isInitialized
		ifTrue: [ self closeHandles. ] ]
		ensure: [ self forgetInitializationState ]
]

{ #category : #'accessing platform' }
LWpaLibrary >> unixModuleName [
	| pluginDir |
	pluginDir := Smalltalk vm binary parent.
	#('libwpa.so' 'libwpa.so.0')
		detect: [ :each | (pluginDir / each) exists ] 
		ifFound: [ :libName | ^ libName ].

	self error: 'Module not found.'
]

{ #category : #'accessing platform' }
LWpaLibrary >> win32ModuleName [ 
	self error: 'Module not found.'
]
