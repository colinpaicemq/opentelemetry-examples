docker run --rm  \
  --name prometheus \
  -p 9090:9090 \
  -p 8080:8080 \
  -v $(pwd)/prom2.yaml:/etc/prometheus/prometheus.yml \
  -v $(pwd)/prom2.yaml:/prometheus/prometheus.yml \
  --network otel-jaeger-network \
  prom/prometheus:latest --log.level=debug --enable-feature=promql-experimental-function

