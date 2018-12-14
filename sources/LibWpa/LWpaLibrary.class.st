"
This library is meant to provide the functionality of the wpa_supplicant control interface to pharo.
https://w1.fi/wpa_supplicant/devel/ctrl_iface_page.html

The used library-module consists mostly of 2 files (and their dependencies): wpa_ctrl.c and wpa_ctrl.h

After cloning the repository with:

git clone git://w1.fi/srv/git/hostap.git

Since this library only exists for unix it does not make sense to use me on other systems as well.
Run this shell script to compile for unix:
#!/bin/sh
cd ""$( dirname ""${BASH_SOURCE[0]}"" )""
make -C ./hostap/src/ clean
rm -r ./build
mkdir ./build
cd ./build
gcc -c -Wall -Werror -fpic ../hostap/src/common/wpa_ctrl.c ../hostap/src/utils/common.c ../hostap/src/utils/os_unix.c -I ../hostap/src/utils/ -I ../hostap/src -DCONFIG_CTRL_IFACE -DCONFIG_CTRL_IFACE_UNIX
gcc -shared -o libwpa.so ./wpa_ctrl.o ./common.o ./os_unix.o
cp ./libwpa.so ../../pharo-vm/lib/pharo/5.0-201806281256/libwpa.so
"
Class {
	#name : #LWpaLibrary,
	#superclass : #FFILibrary,
	#category : #'LibWpa-FFI-Handling'
}

{ #category : #'libwpa-calls' }
LWpaLibrary >> handleResult: resultCode [
	resultCode = -1
		ifTrue: [ LWpaError signal ].
	resultCode = -2
		ifTrue: [ LWpaTimeoutError signal ].
	
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_attach: control [
	| result |
	result := self ffiCall: #(int wpa_ctrl_attach(LWpaControlHandle * control)).
	self validate: result.
	^ self
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_close: control [
	| result |
	result := self ffiCall: #(void  wpa_ctrl_close(LWpaControlHandle * control)).
	self validate: result.
	^ self
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_detach: control [
	| result |
	result := self ffiCall: #(int wpa_ctrl_detach(LWpaControlHandle * control)).
	self validate: result.
	^ self
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_get_fd: control [
	^ self ffiCall: #(int wpa_ctrl_get_fd(LWpaControlHandle * control))
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_open: controlPath [
	| result |
	result := self ffiCall: #(LWpaControlHandle * wpa_ctrl_open(String controlPath)).
	self validate: result.
	^ self
]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_pending: control [
	| result |
	result := self ffiCall: #(int wpa_ctrl_pending(LWpaControlHandle * control)).
	self validate: result.
	^ self

]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_recieve: control [
| writeBackReply writeBackReplyLength result |
	writeBackReply := LWpaWritebackString new.
	writeBackReplyLength := LWpaWritebackSizeT new.
	result := self ffiCall: #(int wpa_ctrl_pending(LWpaControlHandle * control , LWpaWritebackString * writeBackReply , LWpaWritebackSizeT * writeBackReplyLength)).
	self validate: result.
	^ writeBackReply

]

{ #category : #'libwpa-calls' }
LWpaLibrary >> libwpa_request: control command: command [
	| commandLength writeBackReply writeBackReplyLength result |
	commandLength := (command length + 1).
	writeBackReply := LWpaWritebackString new.
	writeBackReplyLength := LWpaWritebackSizeT new.
	result := self ffiCall: #(int wpa_ctrl_request(LWpaControlHandle * control , String cmd , FFISizeT cmd_len , LWpaWritebackString writeBackReply , LWpaWritebackSizeT * writeBackReplyLength , LWpaMessageCallback * nil)).
	self validate: result.
	^ writeBackReply
]

{ #category : #'accessing platform' }
LWpaLibrary >> macModuleName [ 
	self error: 'Module not found.'
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

{ #category : #'libwpa-calls' }
LWpaLibrary >> validate: resultCode [
	resultCode = -1
		ifTrue: [ LWpaError signal ].
	resultCode = -2
		ifTrue: [ LWpaTimeoutError signal ].
	
]

{ #category : #'accessing platform' }
LWpaLibrary >> win32ModuleName [ 
	self error: 'Module not found.'
]
