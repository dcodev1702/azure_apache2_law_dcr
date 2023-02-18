FROM docker.elastic.co/logstash/logstash:8.6.1

RUN rm -f /usr/share/logstash/pipeline/logstash.conf && \
    /usr/share/logstash/bin/logstash-plugin install microsoft-sentinel-logstash-output-plugin
