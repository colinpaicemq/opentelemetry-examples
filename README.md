When I started learning about Opentelemetry there was a lot of good information, but no data to play with.
With this project, I've provided the configurations I have used for Opentelemetry, Jaeger, Prometheus and Grafana, with some data you can use to help you understand the tools.

The examples are not perfect - but they are much better than having no data to play with.

I'll list the files, and what they do.  I'll also give a quick guide to exploring the data.  When I have more time (and there is demand) I'll improve the instruction.

I run on Ubuntu Linux.  I run the various tool each in their own terminal window, so it is easy to canc and restart a tool.  I haven't tested this material on other platforms.

## What's what

- Opentelemetry collector takes Opentelemetry data from work running across silos and converts it to a form suitable for the other tools
- Jaeger takes data and shows the elements of a piece of work, how they are connected, and how long they take
- Prometheus is an efficient database for time series type data.
- Grafana is a visualisation tool - very good with time series data.  You can create dashboards from many data sources.   You can display many metrics on one dashboard.


## List of files in the /src directory

### Identifying what is running
I use multiple windows to run the tools.  I change the title of the terminal windows to match what is running.   I run the bash scripts below using  . oo.sh


- oo.sh  for OTEL
- jj.sh  for Jaeger
- pp.sh  for Promethus
. gg.sh  for Grafana

## Running the tools

### Opentelemetry collector

- o1.sh runs an Opentemetry collector using file input, and the Jaeger output can be displayed in a web browser.  
- o1.yaml  the configuration file for the Opentelemetry configuration used by o1.sh

### Jaeger

- j1.script this runs Jaeger
- j1.yaml this is the configuration file for the j1.script

### Prometheus

- p1.sh this run Prometheus
- p1.yaml is the configuration file for p1.sh

###  Grafana

- g0.sh run this once to configure Grafana
- g1.sh run this for normal operation.   This allows you to save your dashboard configuration

## Data

The OTEL data is in JSON format.  For example

```

  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {
            "key": "telemetry.sdk.language",
            "value": {
              "stringValue": "python"
            }
          },
...

          "spans": [
            {
              "traceId": "a8a55374055bb371574b2ebe5a2c171a",
              "spanId": "5197d1f3c4c74888",
              "parentSpanId": "64ec4fc69c9ec00a",
              "flags": 256,
              "name": "Put code",
              "kind": 1,
              "startTimeUnixNano": 1790360678338434501,
              "endTimeUnixNano": 1790360678349711981,
              "attributes": [
                {
                  "key": "colin",
                  "value": {
                    "stringValue": "colin1"
                  }
                },
                {
                  "key": "colin2",
                  "value": {
                    "stringValue": "line58"
                  }
                }
              ],
              "status": {}
            },

```
where there are start and end times of the work as it was processed.

The OTEL display is usually of the format " in the last 5 minutes", 
or "in the last hour", but a date time range can selected.

The sample data provided has dates from September 2026 which will not be easy to display.  
I've provided some Python code that shifts the startTimeUnixNano and endTimeUnixNano so they are in the current time frame.  
If you use the data, and come back later, 
you may want to rerun the Python code to update the timestamps.

I run my Python programs in a virtual environment.

# Displaying data in Jaeger

## Start Jaeger

```
create a terminal
cd ~/git/opentelemetry/src
. jj.sh
sh jj.sh
```

## Start the Opentelemetry collector
Switch to the virtual environment
```
. nenv/bin/activate 
. oo.sh
cd ~/git/opentelemetry/src
python3 python3 fixtime.py jaeger.json 
``` 
this creates the file otel.in.json, which is referred to in the o1.sh script
```
sh o1.sh
```
This will read the file, and the data will flash by in the window

Open a browser and point it to http://localhost:16686

It may take a minute or two for the data to arrive.

When you have finished shutdown O1 and Jaeger ( I use ctrl-c to cancel them)

# displaying data in Prometheus

I would not normally display data in Prometheus, because Grafana does it better.  But it is occasionally useful to use Proometheus to look at the raw data.

```
Start a terminal
. pp.sh 
sh p1.sh 

Start a terminal, go into your Python environment

python3 python3 fixtime.py prometheus.data.json 

sh o2.sh 

```

Open a web browser with url http://localhost:9090/

- In the input box >_ start typing *trace*, 
it should display the variables available to you.  
Select *traces_span_metrics_duration_milliseconds_count* 
Select *Execute*
Click on Table.   This will display the data records and all the fields.  At the right hand end is the value

For example

```
traces_span_metrics_duration_milliseconds_count                  10
{collector_instance_id="561ed95f-4203-4044-9848-af006708c14f",   
exported_job="CSQ9", instance="ozf:8889", 
job="aggregated-trace-metrics", 
otel_scope_name="spanmetricsconnector", service_name="CSQ9", 
span_kind="SPAN_KIND_CONSUMER", span_name="MQGET CSERVER", 
status_code="STATUS_CODE_UNSET", w3_tracestate="tran=payroll2"}   
```

Click on Graph to display the data as a graph.

There is a box with |- 1h +|  this allows you to zoom in our out of a the time range.  - makes the time interval smaller

Click on *Stacked* to see the data as stacked, giving the total count, ( up to 110)
or *Unstacked* where the values are all from the base line.   All values
are 10 - so it doesnt show much

Selec *Stacked* and move the cursor over the colours.   You can see the information for that block of data

Below the graph is the data.  Click on the top value - and you see the graph just for that value.  Click it again to see all data.

Change the query to *traces_span_metrics_duration_milliseconds_sum/traces_span_metrics_duration_milliseconds_count*

This gives you the average time for all the spans.   This is confusing becaus the biggest value (span name=payroll) is the total transaction, above this are the individual spans.... so we have double accounting here.
