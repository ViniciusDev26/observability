FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
  curl unzip wget tar supervisor && \
  mkdir -p /etc/supervisor/conf.d /opt/otel

# Install Prometheus
RUN curl -LO https://github.com/prometheus/prometheus/releases/download/v2.49.1/prometheus-2.49.1.linux-amd64.tar.gz && \
    tar -xvf prometheus-2.49.1.linux-amd64.tar.gz && \
    mv prometheus-2.49.1.linux-amd64 /opt/prometheus

# Install Grafana
RUN mkdir -p /opt/grafana
RUN wget https://dl.grafana.com/oss/release/grafana-10.2.3.linux-amd64.tar.gz && \
    tar -zxvf grafana-10.2.3.linux-amd64.tar.gz && \
    ls . && \
    mv grafana-v10.2.3 /opt/grafana

# Install Loki
RUN curl -LO https://github.com/grafana/loki/releases/download/v2.9.5/loki-linux-amd64.zip && \
    unzip loki-linux-amd64.zip && chmod +x loki-linux-amd64 && \
    mv loki-linux-amd64 /usr/local/bin/loki

# Install Tempo
RUN curl -Lo tempo_2.2.0_linux_amd64.deb https://github.com/grafana/tempo/releases/download/v2.2.0/tempo_2.2.0_linux_amd64.deb && \
  echo e81cb4ae47e1d8069efaad400df15547e809b849cbb18932e23ac3082995535b \
  tempo_2.2.0_linux_amd64.deb | sha256sum -c && \
  dpkg -i tempo_2.2.0_linux_amd64.deb

RUN mkdir -p /var/log
RUN mkdir -p /tempo/traces

# Copy configs
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY loki-config.yaml /etc/loki/loki-config.yaml
COPY tempo-config.yaml /etc/tempo/tempo-config.yaml
COPY grafana /opt/grafana/conf

EXPOSE 3000 9090 3100 3200

CMD ["/usr/bin/supervisord", "-n"]
