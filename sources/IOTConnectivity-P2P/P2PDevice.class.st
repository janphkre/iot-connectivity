"
I am a convenience p2p device representing all actions that are connected to p2p on a wpacli.
I represent the following commands on wpa_cli:
p2p_service_add           p2p_service_flush         p2p_service_update        p2p_flush
p2p_find                  p2p_stop_find             p2p_peers                 p2p_listen
p2p_reject                p2p_invite                

Currently not implemented commands are:
p2p_asp_provision         p2p_group_add                             
p2p_asp_provision_resp    p2p_group_remove          p2p_remove_client         p2p_service_rep
p2p_cancel                p2p_serv_disc_cancel_req  p2p_service_update
p2p_connect               p2p_serv_disc_external    p2p_set
p2p_ext_listen            p2p_peer                  p2p_serv_disc_req
p2p_serv_disc_resp        p2p_unauthorize
p2p_presence_req                    
p2p_get_passphrase        p2p_prov_disc             p2p_service_del

I present the following message to my users:
serviceAdd: -> p2p_service_add <bonjour|upnp> <query|version> <response|service> = add a local service
serviceFlush -> p2p_service_flush = remove all stored service entries
flush -> p2p_flush = flush P2P state
find: -> p2p_find  [timeout]  dev_id=  type=social  delay=  type=progressive
stopFind -> p2p_stop_find
peers -> p2p_peers  [discovered] = list known (optionally, only fully discovered) P2P peers
listen -> p2p_listen  [timeout] = listen for P2P Devices for up-to timeout seconds
reject -> p2p_reject  peer=addr = block peer
invite -> p2p_invite  peer=addr = invite peer

A correct P2P-Serv-disc-resp is:

P2P-SERV-DISC-RESP 96:65:2d:d6:65:74 7 57000101000b746573747365727669636512706861726f5f636f6e6e6563746976697479c0110010012f6964656e7469666965723d37623263633534652d373934342d346630352d623938362d643539633230353364336537290001010012706861726f5f636f6e6e6563746976697479c011000c010b5465737453657276696365c027

Our Current P2pServDiscResp is:

P2P-SERV-DISC-RESP 34:41:5d:e0:e5:d0 12 54000101002474657374736572766963652e706861726f5f636f6e6e65637469766974792e6c6f63616c0c001001276964656e7469666965723d746573746964656e7469666965722d666f722d706861726f2d703270

"
Class {
	#name : #P2PDevice,
	#superclass : #WpaCli,
	#category : #'IOTConnectivity-P2P-FFI-Access'
}

{ #category : #commands }
P2PDevice class >> interfaces [
	"List all P2PDevices"
	^ super interfaces
	select: [ :interface |
	interface 	beginsWith: 'p2p-dev' ].
]

{ #category : #commands }
P2PDevice >> invite: aString [
	^ (self command: 'invite ', aString) beginsWith: 'OK'
]

{ #category : #accessing }
P2PDevice >> openSocket [
	"Opens a Socket for this device."
	^ nil
]

{ #category : #commands }
P2PDevice >> reject: aString [
	^ (self command: 'p2p_reject ', aString) beginsWith: 'OK'
]
