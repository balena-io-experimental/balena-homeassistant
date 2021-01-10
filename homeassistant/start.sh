#!/bin/bash

cp /tmp/configuration.yaml /config/configuration.yaml
cp -R /tmp/custom_components /config/
cp -R /tmp/themes /config/

cp /tmp/sensors.yaml /config/sensors.yaml
cp /tmp/sensors.sh /config/sensors.sh
cp /tmp/lovelace.sh /config/lovelace.sh

chmod +x /config/sensors.sh
chmod +x /config/lovelace.sh

if [ ! -f /config/ui-lovelace.yaml ]; then cp /tmp/ui-lovelace.yaml /config/ui-lovelace.yaml; fi

python -m homeassistant --config /config
