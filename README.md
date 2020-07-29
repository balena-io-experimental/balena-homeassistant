# Balena Home Assistant
Home Assistant with balenaSense using MQTT

A full step-by-step tutorial is available here: [https://www.balena.io/blog/monitor-air-quality-around-your-home-with-home-assistant-and-balena/](https://www.balena.io/blog/monitor-air-quality-around-your-home-with-home-assistant-and-balena/)

[Home Assistant](https://www.home-assistant.io/) is a popular open source home automation system that is often run from low-cost devices like a Raspberry Pi. Here’s how to use balenaSense to push its sensor data to Home Assistant using MQTT.

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

We recommend this button as the de-facto method for deploying new apps on balenaCloud, but as an alternative, you can set this project up with the repo and balenaCLI if you choose. Get the code from this repo, and set up [balenaCLI](https://github.com/balena-io/balena-cli) on your computer to push the code to balenaCloud and your devices. [Read more](https://www.balena.io/docs/learn/deploy/deployment/).

## Configuring Home Assistant
A text editor called Hass-Configurator is available locally on port 3218. Using this editor, you can make changes to the Home Assistant configuration file /hass-config/configuration.yaml which is the default folder for Hass-Configurator.

You can enable MQTT in Home Assistant from the Configuration > Integrations menu or by adding the following lines to configuration.yaml:
```
mqtt:  
  broker: mqtt
```
(note that there must be two spaces before the word broker.) Here we are telling Home Assistant to enable MQTT, and providing the hostname of our local MQTT broker container (you could also provide the IP address of the local container or the IP address of any other reachable broker you might want to use.) Any time you change the configuration, you should go back to Home Assistant and use its configuration checker to make sure your changes do not contain any errors. If there are no errors, restart Home Assistant for your changes to take effect.

## Configuring HASS Configurator
Environment varibles can be used to configure the configurator. For example, to add basic HTTP authentication, the `HC_USERNAME` and `HC_PASSWORD` variables can be specified. The password in plain text or via SHA256 by prepending the hash with `{sha256}`. For more information on configurator variables visit: https://github.com/danielperna84/hass-configurator/wiki/Configuration

Note that to specify any of these configuration variables as an environment variable they should be prepended with `HC_`.

## Integrate Home Assistant with balenaSense
You can follow the [balenaSense tutorial](https://www.balena.io/blog/build-an-environment-and-air-quality-monitor-with-raspberry-pi/) to create a self-contained air quality monitoring device. Confirm that your balenaSense installation is up and running on the same network as this project.

Add a device variable to your balenaSense device in the balenaCloud dashboard. In the “Add variable” popup, for “NAME” enter TELEGRAF_MQTT_URL_PORT and then paste the IP from your Home Assistant application into the “VALUE” box. Append :1883 after the address which is the port number. After clicking "Add" balenaSense will restart and begin publishing its sensor data to Home Assistant.

Before we can actually see the sensors in Home Assistant, we need to add them to the configuration.yaml file. You can see the sensors we want to add by opening the file /hass-config/sense.yaml in the configuration editor. Copy the full contents of this file and paste into the bottom of the configuration.yaml file.

Alternatively, you can run a script we prepared to do the copying for you. In the Hass-Configurator, click the gear icon in the upper right and select “Execute shell command.” In the popup box, type /hass-config/sensors.sh and click “Execute.” Almost immediately, you should see “Task completed!” at which point you can click “Close.” Remember to restart Home Assistant to see the changes.

To see a pre-formatted Lovelace version of the UI in Home Assistant, activate it by adding the following to configuration.yaml:
```
lovelace:  
  mode: yaml
```
This change will cause Home Assistant to utilize the ui-lovelace.yaml file we have included.

### Get it going and let us know what you think
Once you have the project up and running, experiment with different setups and configurations to suit your needs! As always, if you run into any problems or have any questions or suggestions, reach out to us on [the forums](https://forums.balena.io/), [Twitter](https://twitter.com/balena_io?ref_src=twsrc%5Egoogle%7Ctwcamp%5Eserp%7Ctwgr%5Eauthor) or [Facebook](https://www.facebook.com/balenacloud/).
