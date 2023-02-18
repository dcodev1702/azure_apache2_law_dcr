FROM docker.elastic.co/logstash/logstash:8.6.1

USER 0

RUN rm -f /usr/share/logstash/pipeline/logstash.conf && \
    mkdir -p /tmp/logstash && \
    /usr/share/logstash/bin/logstash-plugin install microsoft-sentinel-logstash-output-plugin

USER $CONTAINER_USER_ID
