#touch foo.file
#touch fooout.file
#touch foob.json 
#touch file.in.json
#truncate -s 0 file.in.json
#truncate -s 0 foo.file
#truncate -s 0 foob.json 
#chmod 777 f*
#pc="print-initial-config"
#pc=""


docker run --rm  --name ozf \
 --volume "$(pwd)/o2.yaml":"/otel-config.yaml" \
  -v "$(pwd)/otel.in.json":"/input.json" \
  --env COLLECTOR_OTLP_ENABLED=true \
  --publish 4317:4317 \
  --publish 4318:4318 \
  --network otel-jaeger-network \
    otel/opentelemetry-collector-contrib:latest --config otel-config.yaml  
