#!/bin/bash

if grep "balenaSense sensors added by script" /hass-config/configuration.yaml ; then
    # code if comment found in file
    echo 'Sensors already exist in config'
else
    # code if comment not found in file
    cat /hass-config/sense.yaml >> /hass-config/configuration.yaml
    echo 'Task completed!'
fi
