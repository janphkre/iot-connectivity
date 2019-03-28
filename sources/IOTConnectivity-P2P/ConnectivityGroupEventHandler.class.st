Class {
	#name : #ConnectivityGroupEventHandler,
	#superclass : #EventHandler,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #'instance creation' }
ConnectivityGroupEventHandler class >> on: aService [
	^ self new service: aService.
]

{ #category : #events }
ConnectivityGroupEventHandler >> AP_STA_CONNECTED: anEvent [
 "Can be ignored"
]

{ #category : #events }
ConnectivityGroupEventHandler >> AP_STA_DISCONNECTED: anEvent [
 "Can be ignored"
]

{ #category : #events }
ConnectivityGroupEventHandler >> CTRL_EVENT_EAP_FAILURE: anEvent [
]

{ #category : #events }
ConnectivityGroupEventHandler >> CTRL_EVENT_EAP_PROPOSED_METHOD: anEvent [
]

{ #category : #events }
ConnectivityGroupEventHandler >> CTRL_EVENT_EAP_STARTED: anEvent [
]

{ #category : #events }
ConnectivityGroupEventHandler >> WPS_ENROLLEE_SEEN: anEvent [
  "Only an informational event of devices that we noticed for this group device."
]

{ #category : #events }
ConnectivityGroupEventHandler >> WPS_PBC_ACTIVE: anEvent [
	"Ignore this event, it suggests that push button connection for wps is currently active."
]

{ #category : #events }
ConnectivityGroupEventHandler >> WPS_PBC_DISABLE: anEvent [
  "This event means that a device used WPS PBC."
  service groupWpsPbc.
]

{ #category : #events }
ConnectivityGroupEventHandler >> WPS_REG_SUCCESS: anEvent [
]

{ #category : #events }
ConnectivityGroupEventHandler >> WPS_SUCCESS: anEvent [
  "This event means that a device used WPS PBC successfully."
]

{ #category : #events }
ConnectivityGroupEventHandler >> WPS_TIMEOUT: anEvent [
 service groupWpsPbc.
]
