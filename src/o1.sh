# Run the open telemetry collector
# touch the files so they exist and give them the correct access
#touch foo.file
#touch fooout.file
#touch foob.json 
#touch file.in.json
truncate -s 0 file.in.json
truncate -s 0 foo.file
truncate -s 0 foob.json 
#chmod 777 f*
pc=""  # used for passing any parameters


docker run --rm  --name ozf \
 --volume "$(pwd)/o1.yaml":"/otel-config.yaml" \
  -v "$(pwd)/otel.in.json":"/input.json" \
  --env COLLECTOR_OTLP_ENABLED=true \
  --publish 4317:4317 \
  --publish 4318:4318 \
  --network otel-jaeger-network \
    otel/opentelemetry-collector-contrib:latest ${pc}  --config otel-config.yaml 
    
#  -v "$(pwd)/tempcert.pem":"/server.pem" \
#  -v "$(pwd)/tempcert.key.pem":"/server.key.pem" \
#  -v "$(pwd)/foo.file":"/fooin.file" \
#  -v "$(pwd)/fooout.json":"/fooout.file" \
#  -v "$(pwd)/foob.json":"/b.file" \    
