'''
Python  script to adjust the datetimes in an opentelemety json file, so it looks as it the data
has just been created.

This has been tested on Ubuntu

Format

python3 fixtime filename1 <filename2>

Where 
filename1 is the name of the input file
filename2 is the name of the output file.   The default is otelts.json 

'''
import csv, json
import sys
import json
from datetime import datetime
import json 
import time
earliestTime = 0
if len(sys.argv) < 1:
    print("fixtime adjusts the otel datetime stampts in otel data to look like they've just been created")
    print("The format is fixtime  <inputfile> <outputfile>")
    print("Where the defaults are  inputfile is file.in.json and the outputfile is otel.in.json ")
    sys.exit(0)
if len(sys.argv) < 2:
   inputFile =  "file.in.json" 
else:
    inputFile  = sys.argv[1]   
if len(sys.argv) < 3:
   outputFile =  "otel.in.json" 
else:
    outputFile  = sys.argv[2]       
timenow = time.time_ns() 
lineno = 0
with open(inputFile, 'r') as file, open(outputFile, 'w') as fout:
# first time set up data - first and last times and link span to the scopespan 
    for line in file:
        data = json.loads(line)
        # get the first time - so we can offset all of the time values
        if earliestTime == 0:  # get the first time found in a span
            for d,dvalue in data.items():  # a dict with one item, resourceSpans
                for resourceSpan in dvalue :   # it is a list - do each one
                    scopeSpans= resourceSpan["scopeSpans"]
                    for scopeSpan in scopeSpans:  #"scopeSpans": [ is a list of scopes
                            spans = scopeSpan["spans"]  # a dict
                            # print(spans)
                            for s in spans:  # each span  in the list Only element
                                # s["scopeSpan"] = scopeSpan
                                earliestTime = s["startTimeUnixNano"]
                                delta = timenow- int(earliestTime)
                                break
                            break
                    break
        # now process all of the data and add the delta to the time stampb       
        for d,dvalue in data.items():  # a dict with one item resourceSpans                    
            for resourceSpan in dvalue :   # it is a list - do each one
                scopeSpans= resourceSpan["scopeSpans"]                
                for scopeSpan in scopeSpans:  #"scopeSpans": [ is a list of scopes
                    spans = scopeSpan["spans"]  # a dict
                    # print(spans)
                    for s in spans:  # each span  in the list Only element
                        s["startTimeUnixNano"] = int(s["startTimeUnixNano"]) + delta 
                        s["endTimeUnixNano"] = int(s["endTimeUnixNano"])  +delta
        # and now write out the updated data  
        jsonstr = json.dumps(data)
        fout.write(jsonstr+"\n")                                 

sys.exit(0)