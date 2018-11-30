"
I am a convenience p2p device representing all actions that are connected to p2p on a wpacli.
This represents the following messages on wpacli:
p2p_asp_provision         p2p_group_add             p2p_reject                p2p_service_flush
p2p_asp_provision_resp    p2p_group_remove          p2p_remove_client         p2p_service_rep
p2p_cancel                p2p_invite                p2p_serv_disc_cancel_req  p2p_service_update
p2p_connect               p2p_listen                p2p_serv_disc_external    p2p_set
p2p_ext_listen            p2p_peer                  p2p_serv_disc_req         p2p_stop_find
p2p_find                  p2p_peers                 p2p_serv_disc_resp        p2p_unauthorize
p2p_flush                 p2p_presence_req          p2p_service_add           
p2p_get_passphrase        p2p_prov_disc             p2p_service_del


"
Class {
	#name : #P2PDevice,
	#superclass : #WpaCli,
	#category : #'IOTConnectivity-P2P'
}

{ #category : #commands }
P2PDevice class >> interfaces [
	"List all P2PDevices"
	| interfaceList |
	interfaceList := super interfaces.
	
	^ interfaceList.
]

{ #category : #acccessing }
P2PDevice >> openSocket [
	"Opens a Socket for this device."
	^ nil
]
