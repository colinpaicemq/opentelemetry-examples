When I started learning about Opentelemetry there was a lot of good information, but no data to play with.
With this project, I've provided the configurations I have used for Opentelemetry, Jaeger, Prometheus and Grafana, with some data you can use to help you understand the tools.

The examples are not perfect - but they are much better than having no data to play with.

I'll list the files, and what they do.  I'll also give a quick guide to exploring the data.  When I have more time (and there is demand) I'll improve the instruction.

I run on Ubuntu Linux.  I run the various tool each in their own terminal window, so it is easy to canc and restart a tool.  I haven't tested this material on other platforms.

I use dockerto create my images - it is easy and it works.  For OTEL, Jaeger and Prometheus, Ive configured it so the data is deleted every time.
For Grafana, the data is not deleted, so you can save dashboards and other configuation across sessions.

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
- gg.sh  for Grafana

## Running the tools

### Opentelemetry collector

- o1.sh runs an Opentemetry collector using file input, and the Jaeger output can be displayed in a web browser.  
- o1.yaml  the configuration file for the Opentelemetry configuration used by o1.sh
- o2.sh this is used to use Prometheus and Grafana
- o2.yaml the definitions needed for o2.sh .

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
Switch to the virtual environment, and reset the dates in the data
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
This will read the file, and the data will flash by in the terminal window

Open a browser and point it to http://localhost:16686

It may take a minute or two for the data to arrive.  Click on refresh or search

When you have finished shutdown O1 and Jaeger ( I use ctrl-c to cancel them).

# Displaying data in Prometheus

I would not normally display data in Prometheus, 
because Grafana does it better.  
But it is occasionally useful to use Prometheus to look at the raw data.

The instructions below use a different OTEL script - because it uses a different configuration file o2.yaml.

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
Select *traces_span_metrics_duration_milliseconds_count* . 
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
are 10 - so it doesnt show much.

Select *Stacked* and move the cursor over the colours.   You can see the information for that block of data.

Below the graph is the data.  Click on the top value - and you see the graph just for that value.  Click it again to see all data.

Change the query to *traces_span_metrics_duration_milliseconds_sum/traces_span_metrics_duration_milliseconds_count*

This gives you the average time for all the spans.   This is confusing becaus the biggest value (span name=payroll) is the total transaction, above this are the individual spans.... so we have double accounting here.


# Grafana
The first time you need to set up Grafana
```
sh g0.sh
```

Thene you can use
```
python3 python3 fixtime.py prometheus.data.json 
sh o2.sh
sh p1.sh
sh g1.sh
```

Use brower localhost:3000

- Connections -> Add new connection
- Search prometheus, install it if needed
- Click on Add new data source 
- Prometheus servier URL http://prometheus:9090
- No authentication
Go to bottom  - Save and test

* Successfully queried the Prometheus API.
Next, you can start to visualize data by building a dashboard 
from scratch or by querying data in the Explore view.*

Click on Explore view
- Metric - select pulldown for Select Metric
- Select traces_span_metrics_duration_milliseconds_count (and copy it to the clipboard)
- At top clock on refresh (blue box with circulating arrows in it)
- You should get a graph
- In the graph click stacked bars
- Below the graph is Raw 

## Create a dashboard

- Left hand side Dashboard -> New -> New Dashboard
- Click on the blue cross
- Click on Configure vizualisation
- Data Source.  Pull down - select Prometheus
- Metric Pull down -> traces_span_metrics_duration_milliseconds_count
- Top of screen Save (in blue box).  Give it a name
- Top of screen - > Refresh
- Last 6 hours  -> pull down -> last 30 minutes
- Put mouse on a line in the graph
- Back to queries.    
You have query A, and Metrics traces_span_metrics_duration_milliseconds_count.
- Click on Label filters.  Pick span_name = Payroll .
This wil display only those spans with the value. ( Is is w3.tracedata=tran=Payroll ?)
- Select run queries
- Go to top and Save

### Change graph type

- Click on time series change.  Experiment with difference chart type
- Go back to Time series
- Scroll down - play with Panel types, and other attribute

### Data links
- In right hand size... configuring times Series scroll down to *Data links and actions*
- Add 
http://localhost:16686/search?end=${__to}000&limit=20&service=MQPA&start=${__from}000&Tags={"span_name":"MQGET CSERVER"}

- Go back to graph - put mouse on line,  single click... the link is at the bottom

- Go back to the Data links and actions. Click on add action...  cancel
- Click on Value Mapping to see what you can do


## Import a dashboard

There is a file, grafana.dash3.json which contains some work in progress ... it does not match the data

- Select Dashboards from the left side pane
- On the top line +^ select import dashboard
- Drag grafaba.dash.3.json to the top box.
- In any panel select the 3 vertical bots.  
You can select edit to change the panel.

