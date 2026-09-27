# Start the jaeger server
touch prom.out.json
truncate -s 0 prom.out.json
chmod 777 prom.out.json
docker run --rm -ti  --name jaeger2 \
  --env COLLECTOR_ZIPKIN_HOST_PORT=:9411 \
  --env COLLECTOR_OTLP_ENABLED=true \
  --env LOG_LEVEL=debug  \
  --publish 16686:16686 \
  --publish 16685:16685 \
  --publish 16687:16687 \
  --publish 8888:8888 \
  --publish 8889:888 \
  -v "$(pwd)/j1.yaml":"/j1.yaml" \
  -v "$(pwd)/prom.out.json":"/file.out" \
  -v  "$(pwd)/jcconfig.yaml:/path/to/config-ui.json" \
  --network otel-jaeger-network \
  cr.jaegertracing.io/jaegertracing/jaeger:2.20.0  --config j1.yaml 

