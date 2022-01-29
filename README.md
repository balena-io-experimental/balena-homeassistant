# Balena Home Assistant
Home Assistant on balena! Why?
- Easy, secure remote access out of the box - no changes to your router required
- Headless deploy process - no hunting for your device
- Run on a minimal OS optimized for containers
- Device dashboard and SSH access via balenaCloud
- Easy to run additional containers/services alongside Home Assistant 

[Home Assistant](https://www.home-assistant.io/) is a popular open source home automation system that is often run from low-cost devices like a Raspberry Pi. This project provides a bare-minimum install using balena, along with some examples of how to extend your installation and integrate with other projects such as [balenaSense](https://github.com/balenalabs/balena-sense)

## Hardware required
Here’s the list of items required for a basic setup:

* Raspberry Pi 3B or greater (A B+ or 4B works great, and less powerful Pis can be used albeit with lower performance)
* 32GB (or larger) Micro-SD Card (we recommend Sandisk Extreme Pro SD cards)
* Power supply and cable
* Optional: For connecting wireless devices such as locks and light switches, a Z-Wave gateway such as the Aeotec Z-Stick Gen5

## Software required
This repository contains all of the software and configuration you’ll need to get started. We’re going to deploy this project on balenaCloud using a free account to push the project and all the software to your Raspberry Pi as well as to provide remote access. Therefore, you’ll need:

* A tool to flash your SD card, such as [balenaEtcher](https://www.balena.io/etcher/)
* A free [balenaCloud](https://dashboard.balena-cloud.com/login) account
* A clone or download of our project from GitHub

## Software setup

Running this project is as simple as deploying it to a balenaCloud application, then downloading the OS image from the dashboard and flashing your SD card.

[![](https://balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy)

We recommend this button as the de-facto method for deploying new apps on balenaCloud, especially if you are just getting started or want to test out the project. However, if you want to modify the docker-compose or tinker with the code, you'll need to clone this repo and use the [balenaCLI](https://github.com/balena-io/balena-cli) to push to your devices. This can be done later if you initially deploy using the button above. [Read more](https://www.balena.io/docs/learn/deploy/deployment/).

### First login
To access your new Home Assistant instance, browse to the IP address of your device. You can find the device's IP address in your balenaCloud dashboard. Go through the Home Assistant setup process and establish a username and password. To obtain a secure public URL for your Home Assistant instance, simply click the "Public Device URL" switch on your balenaCloud dashboard. You'll then see a link to access your unique device URL.

## File Locations

Our project's docker-compose file creates a persistent volume on your disk/SD card for storing Home Assistant configuration files. These are located in the `/config` folder.

## Configuring Home Assistant
A text editor called Hass-Configurator is available locally on port 3218. (To access this: http://192.168.1.120:3218 - but substitute the local IP address of your Home Assistant) Using this editor, you can make changes to the Home Assistant configuration file `configuration.yaml` which is the in the default folder `hass-config` for Hass-Configurator. (`hass-config` is mapped to `/config`)

You can [enable MQTT](https://www.home-assistant.io/integrations/mqtt/) in Home Assistant from the Configuration > Devices & Services > Add Integration button (for "broker" enter `mqtt`) or by adding the following lines to configuration.yaml:
```
mqtt:  
  broker: mqtt
```
(note that there must be two spaces before the word broker.) Here we are telling Home Assistant to enable MQTT, and providing the hostname of our local MQTT broker container (you could also provide the IP address of the local container or the IP address of any other reachable broker you might want to use.) Any time you change the configuration, you should go back to Home Assistant and use its configuration checker to make sure your changes do not contain any errors. If there are no errors, restart Home Assistant for your changes to take effect.

## Configuring HASS Configurator
[Environment variables]([environment variable](https://www.balena.io/docs/learn/manage/variables/)) can be used to configure the configurator. For example, to add basic HTTP authentication, the `HC_USERNAME` and `HC_PASSWORD` variables can be specified. The password in plain text or via SHA256 by prepending the hash with `{sha256}`. For more information on configurator variables visit: https://github.com/danielperna84/hass-configurator/wiki/Configuration

Note that to specify any of these configuration variables as an environment variable they should be prepended with `HC_`.

## Home automation with Zigbee and Z-Wave
To unleash the full power of Home Assistant, you can add the ability to control and automate lights, locks, sensors etc... by adding radio-controlled equipment to your installation. Two of the popular protocols for radio-controlled devices are Zigbee and [Z-Wave](https://www.z-wave.com/). These are not compatible systems, so it's best to choose one and stick with it.

### Z-Wave
To control devices using Z-Wave you'll need a compatible gateway device, as well as one or more Z-Wave lights, switches, outlets, etc... More information about these devices can be found [here](https://www.home-assistant.io/integrations/zwave_js/). To use the Home Assistant recommended Z-Wave JS integration, you'll need to plug your gateway (We used a Aeotec Z-Stick Gen5 for our testing) into the device's USB port, and then add a JS server to your docker-compose similar to this:

```
  zjs:
    container_name: zjs
    image: kpine/zwave-js-server:latest
    restart: unless-stopped
    privileged: true
    environment:
      USB_PATH: "/dev/ttyACM0"
      S0_LEGACY_KEY: "27DAB0C1BAD5DABFF74E4B5274E257C3"
    volumes:
      - cache:/cache
    ports:
      - '3000:3000' 
```

You'll also need to add `cache:` to the volumes section of the file to use the above example. (More information about this container setup can be found [here](https://hub.docker.com/r/kpine/zwave-js-server).) Note that you will need to generate a random `S0_LEGACY_KEY` and possibly other keys as well - see the linked container documentation. For the `USB_PATH:` you will need to know the device name for your Z-Wave gateway hardware. `/dev/ttyACM0` is a typical value, but you can ssh into the HostOS and run `ls /dev` to see a list of devices. You may need to compare the list with the gateway plugged in and not plugged in to determine the name.

Once you've updated the docker-compose file, push the updated project to your fleet using the balenaCLI.

To complete the Z-Wave setup, you'll need to use the Home Assistant UI and select configuration > Devices & Services > + add integration > Z-Wave JS. For the URL, enter `ws://zjs:3000` and you should receive a "Success!" message.

### Zigbee

Setup information coming soon!

## Integrate Home Assistant with balenaSense
You can follow the [balenaSense tutorial](https://www.balena.io/blog/balenasense-v2-updated-temperature-pressure-and-humidity-monitoring-for-raspberry-pi/) to create a self-contained air quality monitoring device. Confirm that your balenaSense installation is up and running on the same network as this project.

The balenaSense tutorial also has a section about [Home Assistant integration](https://www.balena.io/blog/balenasense-v2-updated-temperature-pressure-and-humidity-monitoring-for-raspberry-pi/#integration-with-home-assistant-span-idhome-assistantspan). To summarize:

Using the balenaCloud dashboard, add an `MQTT_ADDRESS` device variable to your balenaSense project's "sensor" service with a value of your Home Assistant device's IP address. Make sure MQTT is enabled as described above. 

Before we can actually see the sensors in Home Assistant, we need to add them to the configuration.yaml file in the "sensor" section. The sensor values from balenaSense will have the MQTT topic of `sensors` and each value will have a separate name, depending on the type of sensor. For instance, the sensor value names for a bme680 would be: temperature, pressure, humidity and resistance.  To get the names of all your available sensor values, look at the names above the values in your balenaSense dashboard. 

Using the HASS Configurator, open the configuration.yaml file and add the sensors under the `sensor:` section. (If that section does not exist, you can add it.) We'll use the Home Assistant mqtt sensor platform and a json value_template syntax as shown in the following example for a bme 680:

```
sensor:
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ value_json.humidity }}"
    name: "sense_humidity"
    unit_of_measurement: "%"
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ value_json.temperature }}"
    name: "sense_temperature_c"
    unit_of_measurement: "degrees"
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ ((float(value_json.temperature) * 9 / 5) + 32) | round(1) }}"
    name: "sense_temperature_f"
    unit_of_measurement: "degrees"
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ value_json.pressure }}"
    name: "sense_pressure"
    unit_of_measurement: "mbar"
```
    
Save the file and restart Home Assistant for the changes to take effect.

If you don't need a full balenaSense installation but want to integrate a sensor directly with Home Assistant, follow our guide for [including the sensor block](https://www.balena.io/blog/balenasense-v2-updated-temperature-pressure-and-humidity-monitoring-for-raspberry-pi/#use-a-sensor-attached-to-your-device-running-home-assistant-on-balenaos-span-idsensorspan) in your project.

## Other integrations

Because we're running containers on balenaOS, it's easy to [add complementary services](https://www.balena.io/blog/two-projects-one-device-turn-your-raspberry-pi-into-a-multitool/) to your project by simply adding them to your docker-compose file. Below are a few of our favorites that work well with Home Assistant. Note that to add these services, you'll need to clone and edit this repository then use the [balenaCLI](https://github.com/balena-io/balena-cli) to push your updated project to your fleet of devices. 

### Frigate
Frigate is a full featured NVR (Network Video Recorder) that integrates nicely with Home Assistant. Check out [this repository](https://github.com/klutchell/balena-frigate) for an example of Frigate running on balena. You could merge the services of that project's docker-compose (except MQTT because we already included it) with this project, as well as copy over the folders and files.
 
### AppDaemon/HADashboard
[AppDaemon](https://appdaemon.readthedocs.io/en/latest/index.html) is an environment for creating Python automations for Home Assistant, but it also includes [HADashboard](https://appdaemon.readthedocs.io/en/latest/DASHBOARD_INSTALL.html) - a beautiful dashboard for Home Assistant that is intended to be displayed on a wall mounted monitor. (HADashboard does not require any Python programming!) To include this functionality, simply add the following to your docker-compose. You can access your dashboards on port 5050 (for instance http://192.168.1.120:5050 - but substitute the local IP address of your Home Assistant)

```
  appdaemon:
    container_name: app-daemon
    image: acockburn/appdaemon:latest
    ports:
      - "5050:5050"
    volumes:
      - config:/conf
    restart: always
    depends_on:
      - homeassistant
```

Once you have added the above to your docker-compose file, re-push the application using the CLI. Next, you'll need to use the HASS Configurator to edit the `appdaemon.yaml` file in `hass-config`. Here is a sample to get you started:

```
appdaemon:
  latitude: 0
  longitude: 0
  elevation: 30
  time_zone: Europe/Berlin
  plugins:
    HASS:
      type: hass
      ha_url: http://192.168.1.120
      token: <your token>
http:
  url: http://192.168.1.120:5050
admin:
api:
hadashboard:
  dash_url: http://192.168.1.120:5050
```

You'll need to substitute the IP address of your device, and create a "Long-Lived Access Token" in Home Assistant by navigating to your profile page, scrolling down, and clicking the "Create Token" button. Use that (very long) value in place of `<your token>`.

### Grafana and InfluxDB
[InfluxDB](https://www.influxdata.com/) is a comprehensive time-series database and [Grafana](https://grafana.com/) is a complentary graphing package to build and display dashboards. Home Assistant can be configured to store some or all of its data in InfluxDB. The Grafana dashboards are well suited to displaying chages in sensor and other values over time, as opposed to current values and more binary information displayed by HADashboard. See [this repo](https://github.com/klutchell/balena-homeassistant) for an example of incorporating InfluxDB and Grafana into your Home Assistant project using balena. At a minimum, you'll need to add the following lines to your docker-compose file:
```
  influxdb:
    image: influxdb:1.8.6
    volumes:
      - influxdb:/var/lib/influxdb

  grafana:
    image: grafana/grafana:8.1.2
    volumes:
      - grafana:/var/lib/grafana
    ports:
        - 3010:3000/tcp
```       

You'll also need to add these lines to the "volumes:" section:
```
    influxdb:
    grafana:
```

After pushing the updated project to your device using the CLI, you'll need to set up the Influx database and then instruct Home Assistant to use it as outlined [here](https://github.com/klutchell/balena-homeassistant#influxdb--grafana). You can also check out the official integration instructions [here](https://www.home-assistant.io/integrations/influxdb) for more information. Grafana will then be available on port 3010 and you can start designing your own dashboards. (Note that we re-mapped Grafana from its usual port of 3000 to avoid conflict with Z-Wave JS)

After you log into Grafana, you'll need to set up a data source on which to base your dashboards. When setting up a data source, use `http://influxdb:8086` as the HTTP URL and `homeassistant` as the database name.

## Putting it all together
Here is an example of merging many of the integrations mentioned above into one docker-compose.yaml file:

```
version: '2'
volumes:
    config:
    mosquitto:
    influxdb:
    grafana:
    cache:
services:
  homeassistant:
    build: homeassistant
    ports:
      - 80:8123
    privileged: true
    volumes:
      - 'config:/config'
      - 'cache:/mycache'
    restart: always
  mqtt:
    build: mqtt
    ports:
      - "1883:1883"
    restart: always
    volumes:
      - mosquitto:/mosquitto/data
  hass-configurator:
    image: "causticlab/hass-configurator-docker:arm"
    restart: always
    ports:
      - "3218:3218"
    volumes:
      - 'config:/hass-config'
    environment:
      - HC_BASEPATH=/hass-config
  appdaemon:
    container_name: app-daemon
    image: acockburn/appdaemon:latest
    ports:
      - "5050:5050"
    volumes:
      - config:/conf
    restart: always
    depends_on:
      - homeassistant
  influxdb:
    image: influxdb:1.8.6
    volumes:
      - influxdb:/var/lib/influxdb
  grafana:
    image: grafana/grafana:8.1.2
    volumes:
      - grafana:/var/lib/grafana
    ports:
        - 3010:3000/tcp    
  zjs:
    container_name: zjs
    image: kpine/zwave-js-server:latest
    restart: unless-stopped
    privileged: true
    environment:
      USB_PATH: "/dev/ttyACM0"
      S0_LEGACY_KEY: "27DAB0C1BAD5DABFF74E4B5274E257C3"
    volumes:
      - cache:/cache
    ports:
      - '3000:3000' 
```

### Get it going and let us know what you think
Once you have the project up and running, experiment with different setups and configurations to suit your needs! As always, if you run into any problems or have any questions or suggestions, reach out to us on [the forums](https://forums.balena.io/), [Twitter](https://twitter.com/balena_io?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor) or [Facebook](https://www.facebook.com/balenacloud/).
