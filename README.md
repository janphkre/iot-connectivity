# Setting up pharo with IOTConnectivity on the Raspberry Pi:

```
wget http://files.pharo.org/vm/pharo-spur32/linux/armv6/pharo-linux-ARMv6-201903251926-4e1be2c.zip
unzip pharo-linux-ARMv6-201903251926-4e1be2c.zip
curl get.pharo.org/70 | bash
cp Pharo.image PharoThings.image
cp Pharo.changes PharoThings.changes
./pharo --headless PharoThings.image eval --save "Iceberg enableMetacelloIntegration: false. Metacello new baseline: 'PharoThings'; repository: 'github://pharo-iot/PharoThings/src'; load: #(RemoteDevServer Raspberry)."
cp PharoThings.image iot.image
cp PharoThings.changes iot.changes
./pharo --headless iot.image eval --save "ClySystemEnvironmentPlugin disableSlowPlugins. Iceberg enableMetacelloIntegration: false. Metacello new repository: 'github://janphkre/iot-connectivity/sources'; baseline: #IOTConnectivity; load."

cp Pharo.image TelePharo.image
cp Pharo.changes TelePharo.changes
./pharo --headless TelePharo.image eval --save "Iceberg enableMetacelloIntegration: false. Metacello new baseline: 'TelePharo'; repository: 'github://pharo-ide/TelePharo'; load: 'Server'."
cp TelePharo.image iot.image
cp TelePharo.changes iot.changes
./pharo --headless iot.image eval --save "ClySystemEnvironmentPlugin disableSlowPlugins. Iceberg enableMetacelloIntegration: false. Metacello new repository: 'github://janphkre/iot-connectivity/sources'; baseline: #IOTConnectivity; load."

```
```
service := ConnectivityService onDefault: 8889.
service target: 'wlo1'.
service start.
service stop.
service targetDevice scan.
service targetDevice scanResults.
service scan.
service targetDevice status.

LWpaControl allInstances.
LWpaControl registry: WeakRegistry new.
SmalltalkImage current garbageCollect.
```
```
Metacello new
    repository: 'github://zweidenker/JSONSchema/source';
    baseline: #JSONSchema;
    load.
Metacello new
    repository: 'github://zweidenker/OpenAPI/source';
    baseline: #OpenAPI;
    load.

Gofer new
    squeaksource: 'MetacelloRepository';
    package: 'ConfigurationOfOSProcess';
    load.

((Smalltalk at: #ConfigurationOfOSProcess) project version: #stable) load.
```

To create the iot image basing on the telepharo image run this script:
```
cp TelePharo.image iot.image
cp TelePharo.changes iot.changes
./pharo --headless iot.image eval --save "ClySystemEnvironmentPlugin disableSlowPlugins.Iceberg enableMetacelloIntegration: false.Metacello new repository: 'github://janphkre/iot-connectivity/sources'; baseline: #IOTConnectivity; load."
```
