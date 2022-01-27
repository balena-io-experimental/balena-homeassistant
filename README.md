# Balena Home Assistant
Home Assistant on balena! Why?
- Easy, secure remote access out of the box - no changes to your router required
- Headless deploy process - no hunting for your device
- Run on a minimal OS optimized for containers
- Device dashboard and SSH access via balenaCloud
- Easy to run additional containers/services alongside Home Assistant 

[Home Assistant](https://www.home-assistant.io/) is a popular open source home automation system that is often run from low-cost devices like a Raspberry Pi. This project provides a bare-minimum install using balena, along with some examples on how to extend your installation and integrate with other projects such as [balenaSense](https://github.com/balenalabs/balena-sense)

## Hardware required
Here’s the list of items required for a basic setup:

* Raspberry Pi 3B or greater (A B+ or 4B works great, and less powerful Pis can be used albeit with lower performance)
* 32GB (or larger) Micro-SD Card (we recommend Sandisk Extreme Pro SD cards)
* Power supply and cable
* Optional: For connecting wireless devices such as locks and light switches, a Z-Wave gateway such as the Aeotec Z-Stick Gen5

## Software required
This repository contains all of the software and configuration you’ll need to get started. We’re going to deploy this project on balenaCloud using a free account to push the project and all the software to your Raspberry Pi as well as to provide remote access. Therefore, you’ll need:

* A tool to flash your SD card, such as balenaEtcher
* A free balenaCloud account
* A clone or download of our project from GitHub

## Software setup

Running this project is as simple as deploying it to a balenaCloud application, then downloading the OS image from the dashboard and flashing your SD card.

[![](https://balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy)

We recommend this button as the de-facto method for deploying new apps on balenaCloud, especially if you are just getting started or want to test out the project. However, if you want to modify the docker-compose or tinker with the code, you'll need to clone this repo and use the [balenaCLI](https://github.com/balena-io/balena-cli) to push to your devices. This can be done later if you initially deploy using the button above. [Read more](https://www.balena.io/docs/learn/deploy/deployment/).

## File Locations

Our project's docker-compose file creates a persistent volume on your disk/SD card for storing Home Assistant configuration files. These are located in the `/config` folder.

## Configuring Home Assistant
A text editor called Hass-Configurator is available locally on port 3218. Using this editor, you can make changes to the Home Assistant configuration file `/hass-config/configuration.yaml` which is the default folder for Hass-Configurator. (`hass-config` is mapped to `/config`)

You can enable MQTT in Home Assistant from the Configuration > Devices & Services menu or by adding the following lines to configuration.yaml:
```
mqtt:  
  broker: mqtt
```
(note that there must be two spaces before the word broker.) Here we are telling Home Assistant to enable MQTT, and providing the hostname of our local MQTT broker container (you could also provide the IP address of the local container or the IP address of any other reachable broker you might want to use.) Any time you change the configuration, you should go back to Home Assistant and use its configuration checker to make sure your changes do not contain any errors. If there are no errors, restart Home Assistant for your changes to take effect.

## Configuring HASS Configurator
Environment varibles can be used to configure the configurator. For example, to add basic HTTP authentication, the `HC_USERNAME` and `HC_PASSWORD` variables can be specified. The password in plain text or via SHA256 by prepending the hash with `{sha256}`. For more information on configurator variables visit: https://github.com/danielperna84/hass-configurator/wiki/Configuration

Note that to specify any of these configuration variables as an environment variable they should be prepended with `HC_`.

## Integrate Home Assistant with balenaSense
You can follow the [balenaSense tutorial](https://www.balena.io/blog/balenasense-v2-updated-temperature-pressure-and-humidity-monitoring-for-raspberry-pi/) to create a self-contained air quality monitoring device. Confirm that your balenaSense installation is up and running on the same network as this project.

The balenaSense tutorial also has a section about [Home Assistant integration](https://www.balena.io/blog/balenasense-v2-updated-temperature-pressure-and-humidity-monitoring-for-raspberry-pi/#integration-with-home-assistant-span-idhome-assistantspan). To summarize:

Using the balenaCloud dashboard, add an `MQTT_ADDRESS` device variable to your balenaSense project's "sensor" service with a value of your Home Assistant device's IP address. Make sure MQTT is enabled as described above. 

Before we can actually see the sensors in Home Assistant, we need to add them to the configuration.yaml file in the "sensor" section. The sensor values from balenaSense will have the MQTT topic of `sensors` (unless you've changed it) and each value will have a separate name, depending on the type of sensor. For instance, the sensor value names for a bme680 would be: temperature, pressure, humidity and resistance.  To get the names of all your available sensor values, look at the names above the values in your balenaSense dashboard. Using the HASS Configurator, open the configuration.yaml file and add the sensors under the `sensor:` section. (If that section does not exist, you can add it.) For instance, for a bme680, you should have the following:

```
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ value_json.fields.humidity }}"
    name: "sense_humidity"
    unit_of_measurement: "%"
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ value_json.fields.temperature }}"
    name: "sense_temperature_c"
    unit_of_measurement: "degrees"
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ ((float(value_json.fields.temperature) * 9 / 5) + 32) | round(1) }}"
    name: "sense_temperature_f"
    unit_of_measurement: "degrees"
  - platform: mqtt
    state_topic: "sensors"
    value_template: "{{ value_json.fields.pressure }}"
    name: "sense_pressure"
    unit_of_measurement: "mbar"
```
    
Save the file and restart Home Assistant for the changes to take effect.

If you don't need a full balenaSense installation but want to integrate a sensor directly with Home Assistant, follow our guide for including the sensor block in your project.

## Other integrations

### Frigate

### AppDaemon/HADashboard

### 

### Get it going and let us know what you think
Once you have the project up and running, experiment with different setups and configurations to suit your needs! As always, if you run into any problems or have any questions or suggestions, reach out to us on [the forums](https://forums.balena.io/), [Twitter](https://twitter.com/balena_io?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor) or [Facebook](https://www.facebook.com/balenacloud/).
