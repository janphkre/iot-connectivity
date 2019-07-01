# Setting up pharo with IOTConnectivity on the Raspberry Pi:

First setup pharo with the required pacakges as following:

```
#Get pharo packages
wget http://files.pharo.org/vm/pharo-spur32/linux/armv6/pharo-linux-ARMv6-201903251926-4e1be2c.zip
unzip pharo-linux-ARMv6-201903251926-4e1be2c.zip
curl get.pharo.org/70 | bash

#Create TelePharo image

cp Pharo.image TelePharo.image
cp Pharo.changes TelePharo.changes
./pharo --headless TelePharo.image eval --save "Iceberg enableMetacelloIntegration: false. Metacello new baseline: 'TelePharo'; repository: 'github://pharo-ide/TelePharo'; load: 'Server'."

#Create iot connectivity image

cp TelePharo.image iot.image
cp TelePharo.changes iot.changes
./pharo --headless iot.image eval --save "ClySystemEnvironmentPlugin disableSlowPlugins. Iceberg enableMetacelloIntegration: false. Metacello new repository: 'github://janphkre/iot-connectivity/sources'; baseline: #IOTConnectivity; load."

#Start pharo with the image:
sudo ./pharo --headless iot.image eval --no-quit "TlpRemoteUIManager registerOnPort: 40423. (ConnectivityService onDefault: 8889) target: 'wlan1'; start."

```

If you do not want to start the connectivity service immediately you can open a playground on the raspberry pi and start and stop the service like this:

```
service := ConnectivityService onDefault: 8889.
service target: 'wlan1'.
service start.
service stop.
```

#Using the REST Interface

The service will start a server on the port 8889 with the above configuration.
This results in the interface specification being available under <hostname>:8889/spec
The interface looks mostly as followed:
```
{

	"openapi" : "3.0.2",

	"paths" : {

		"/interfaces/{interfaceName}" : {

			"get" : {

				"summary" : "A call to acquire an interface.",

				"description" : "An interface may be used to querry its log or update its configuration.",

				"parameters" : [

					{

						"name" : "interfaceName",

						"description" : "The name given to the interface by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					}

				]

			}

		},

		"/spec" : {

			"get" : {

				"summary" : "A call to get the OpenAPI specification for this server.",

				"description" : "",

				"parameters" : [ ]

			}

		},

		"/interfaces/{interfaceName}/networks" : {

			"get" : {

				"summary" : "A call to get available networks of an interface.",

				"description" : "Returns a collection of available networks for a given network interface.",

				"parameters" : [

					{

						"name" : "interfaceName",

						"description" : "The name given to the interface by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					}

				]

			}

		},

		"/interfaces/{interfaceName}/config" : {

			"get" : {

				"summary" : "A call to create network configurations.",

				"description" : "Provides configuration capabilities for an interface.",

				"parameters" : [

					{

						"name" : "interfaceName",

						"description" : "The name given to the interface by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					}

				]

			},

			"post" : {

				"summary" : "A call to create network configurations.",

				"description" : "Provides configuration capabilities for an interface.",

				"parameters" : [

					{

						"name" : "interfaceName",

						"description" : "The name given to the interface by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					}

				]

			}

		},

		"/interfaces/{interfaceName}/config/{networkId}" : {

			"get" : {

				"summary" : "A call to connect to and reconfigure a configured network.",

				"description" : "Allows a configuration to be selected for connection. Also by passing in new settings the configuration will be altered.",

				"parameters" : [

					{

						"name" : "networkId",

						"description" : "The networkId assigned to the configuration by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					},

					{

						"name" : "interfaceName",

						"description" : "The name given to the interface by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					}

				]

			},

			"put" : {

				"summary" : "A call to connect to and reconfigure a configured network.",

				"description" : "Allows a configuration to be selected for connection. Also by passing in new settings the configuration will be altered.",

				"parameters" : [

					{

						"name" : "networkId",

						"description" : "The networkId assigned to the configuration by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					},

					{

						"name" : "interfaceName",

						"description" : "The name given to the interface by the system.",

						"required" : true,

						"deprecated" : false,

						"allowEmptyValue" : false,

						"allowReserved" : false,

						"in" : "path",

						"schema" : {

							"type" : "string"

						}

					}

				]

			}

		},

		"/interfaces" : {

			"get" : {

				"summary" : "A call to aquire a list of available network interfaces.",

				"description" : "Returns a collection of available network interfaces. An interface can be used to configure its network settings and query it`s log.",

				"parameters" : [ ]

			}

		}

	}

}
```

This repository als contains a ./android-app that can be used together with the pharo rest interface:
![User flow throught the app.][general/latex-ai-prject/user_flow]
The dokumentation of the associated study porject can be found as a PDF [here](./general/latex-ai-project/ai-project-pharo-things.pdf) (History at commit 446207c6a1c41406daed52777f34814cecfb2b2b).

