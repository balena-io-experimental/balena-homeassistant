#!/bin/bash

if grep "lovelace UI added by script" /hass-config/configuration.yaml ; then
    # code if comment found in file
    echo 'UI already exists in config'
else
    # code if comment not found in file
    echo '# lovelace UI added by script' >> /hass-config/configuration.yaml
    echo 'lovelace:' >> /hass-config/configuration.yaml
    echo '  mode: yaml' >> /hass-config/configuration.yaml

    echo 'Task completed!'
fi
