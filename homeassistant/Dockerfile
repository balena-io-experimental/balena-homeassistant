FROM homeassistant/raspberrypi3-homeassistant:stable

COPY sense.yaml /tmp/sense.yaml
COPY ui-lovelace.yaml /tmp/ui-lovelace.yaml
COPY lovelace.sh /tmp/lovelace.sh
COPY sensors.sh /tmp/sensors.sh
COPY start.sh /tmp/start.sh

RUN chmod +x /tmp/start.sh

CMD ["bash","/tmp/start.sh"]
