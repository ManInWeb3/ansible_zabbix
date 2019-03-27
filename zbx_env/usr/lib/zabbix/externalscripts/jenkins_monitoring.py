#!/usr/bin/env python

import time
import argparse
import requests
import xmltodict
import json
import re
import os

JENKINSUSR=''
JENKINSPASS=''
ZABBIX_SERVER= ''  #'127.0.0.1'
#Timeout     (Connect, Read)
REQ_TIMEOUT = (30,30)
DISCOVERY_FREQ_M = 5

JENKINSLABELS = ['linux32bit', 'windows', 'windows-hw-regression', 'windows-hw-test']

def get_queue():
    url = "http://" + args["server"]+"/queue/api/json"
    try:
        resp = session.get(url, timeout=REQ_TIMEOUT)
    except requests.exceptions.RequestException as e:
        # print ("Http Error:",e)
        return None

    queueInfo = resp.json()
    jobs = []
    for j in queueInfo['items']:
        if len(re.findall('BuildableItem$', j['_class']))>0:
            QueueDuration = int(time.time() * 1000 - j['inQueueSince'])/1000
            jobs.append({
                    'url': j['url'], 
                    'queue_duration': QueueDuration,
                    'required_label': j['why'].split()[-1][1:-1]
                })
        else:
            # DOn support other classes
            continue
    return jobs

def get_jobs():
    url = "http://" + args["server"]+"/api/json"
    try:
        resp = session.get(url, timeout=REQ_TIMEOUT)
    except requests.exceptions.RequestException as e:
        # print ("Http Error:",e)
        return []

    serverInfo = resp.json()
    jobs = []
    for j in serverInfo['jobs']:
        if len(re.findall('folder.Folder$', j['_class']))>0 :
            # This is a folder
            docf = session.get(j['url']+'api/json', timeout=REQ_TIMEOUT).json()
            for jf in docf['jobs']:
                if len(re.findall('job.WorkflowJob$', jf['_class']))>0 :
                    jobs.append({'name': jf['name'], 'url': jf['url']})
        elif len(re.findall('job.WorkflowJob$', j['_class']))>0 :
            jobs.append({'name': j['name'], 'url': j['url']})
    return jobs

def JobsInProcess(get_duration=False):
# Request "in_process" jobs from Jenkins API
    url = "http://" + args["server"]+"/computer/api/xml?tree=computer[executors[currentExecutable[url]],oneOffExecutors[currentExecutable[url]]]&xpath=//url&wrapper=builds"
    try:
        response = session.get(url, timeout=REQ_TIMEOUT)
    except requests.exceptions.RequestException as e:
        # print ("Http Error:",e)
        return None

    doc = xmltodict.parse(response.text)
#    doc = xmltodict.parse(re)

    runningBuilds = []

# If there is the only URL then we need to convert it to array to be able to iterate through
# otherwise it will iterate through the string
    if len(re.findall('<url>', response.text))==1:
	doc['builds']['url']=[doc['builds']['url']]

    for b in doc['builds']['url']:
#	print b
	check = session.get(b+'api/json', timeout=REQ_TIMEOUT)
        if check.status_code == 200 :
            runningBuilds.append({"url": b})

    if get_duration :
        for b in runningBuilds:
            try:
                BuildDuration = time.time()*1000 - session.get(b['url']+"api/json", timeout=REQ_TIMEOUT).json()['timestamp']
            except Exception as e:
                BuildDuration = -1
            b.update({'build_duration': BuildDuration})

    return runningBuilds

#
# Defines longes build of the job
# can be BUILD IN PROCESS or lastCompletedBuild (??? what is more helpfull lastCompletedBuild OR lastStableBuild ????????????)
def get_longest_duration(job_url, builds_in_process = None):
    try:
        resp = session.get(job_url+"/api/json", timeout=REQ_TIMEOUT)
    except requests.exceptions.RequestException as e:
        # print ("Http Error:",e)
        return -1

    Jobjson = resp.json()
    try:
        lastSuccessfulBuildjson = session.get(Jobjson['lastSuccessfulBuild']['url']+"/api/json", timeout=REQ_TIMEOUT).json()
        longestBuildDuration = lastSuccessfulBuildjson['duration']
    except Exception as e:
        longestBuildDuration = 0

    if builds_in_process is None:
        runningBuilds = JobsInProcess(True)
    else:
        runningBuilds = builds_in_process

    for b in runningBuilds:
    # If it's the current job build
        if len(re.findall(job_url+'([0-9]+)/', b['url']))>0:
            BuildDuration = b['build_duration']
            if longestBuildDuration < BuildDuration:
                longestBuildDuration = BuildDuration

    return int(longestBuildDuration/1000)

def send_data( hostname, key, value):
    # key=str(key)+"["+str(jobname)+"]"
    # send_cmd = ("%s -c '%s' -k '%s' -o '%s' -s '%s' -vv" % ('C:\zabbix_agents_3.4.6.win\bin\win64\zabbix_sender.exe', 'C:\zabbix_agents_3.4.6.win\conf\zabbix_agentd.win.conf', str(key), str(value), str(hostname)))
    send_cmd = ("%s -z '%s' -k '%s' -o '%s' -s '%s' -vv" % ('/usr/bin/zabbix_sender', ZABBIX_SERVER, str(key), str(value), str(hostname)))
    if args['test'] :
        print(send_cmd)
    else:
        r = os.system(send_cmd)
        if r != 0:
            print(r)
            pass

# dict - can be only 1 level deep, coz it's a set of key: values;
def send_dict( hostname, dict):
    for key, value in dict.iteritems():
        send_data( hostname, str(key), str(value))

# # Losad computers JSON
# def get_computers_statXXXXXXXXXXXXXX():
#     url = "http://" + args["server"]+"/computer/api/json"
#     try:
#         resp = session.get(url, timeout=REQ_TIMEOUT)
#     except requests.exceptions.RequestException as e:
#         # print ("Http Error:",e)
#         return []

#     serverInfo = resp.json()
#     computers = []
#     for j in serverInfo['computer']:
#         if len(re.findall('MasterComputer$', j['_class']))>0:
#             name = j['assignedLabels']['1']['name']
#         elif len(re.findall('SlaveComputer$', j['_class']))>0:
#             name = j['assignedLabels']['0']['name']
#         else:
#             # DOn support other classes
#             continue

#     computers.append({'name': j['assignedLabels']['1']['name'], 'url': j['url']})

#     return computers

def LongestInQueue(queue):
    longest_in_queue = 0
    for q in queue :
        if q['queue_duration'] > longest_in_queue :
            longest_in_queue = q['queue_duration']
    # Convert to min and print
    return int(longest_in_queue/60)


parser = argparse.ArgumentParser(description='Description of your program')
parser.add_argument('-s','--server', help='Jenkins server URL', required=True)
parser.add_argument('-m','--metric', help='Metric to read', default='all')
parser.add_argument('-t','--test', help='Test mode will request all available metrics from all available jobs', dest='test', action='store_true', required=False)
parser.set_defaults(test=False)
parser.add_argument('-u','--url', help='Job URL', required=False)
args = vars(parser.parse_args())

session = requests.Session()
session.auth = (JENKINSUSR, JENKINSPASS)

# Discovery rules

if int(time.strftime("%M")) % DISCOVERY_FREQ_M == 0 :
# Send JOBS discovery
    jobs = get_jobs()
    discovery=[]
    for j in jobs:
        discovery.append({"{#URL}":str(j['url']), "{#NAME}":str(j['name'])})

    send_data( args['server'], 'jobs_discovery', json.dumps({"data": discovery}))

# Send LABELS discovery
    discovery=[]
    for l in JENKINSLABELS:
        discovery.append({"{#NAME}":str(l)})

    send_data( args['server'], 'labels_discovery', json.dumps({"data": discovery}))

# Send required LABELS diskovery
    queue = get_queue()
    discovery = []
    uniq_req_label = set()
    for l in queue:
        uniq_req_label.add( str(l['required_label']) )
    for l in uniq_req_label:
        discovery.append({"{#NAME}": str(l)})

    send_data( args['server'], 'requiredlabels_discovery', json.dumps({"data": discovery}))

if not 'queue' in vars():
    queue = get_queue()

if not 'jobs_in_process' in vars():
    jobs_in_process = JobsInProcess(True)

if not 'jobs' in vars():
    jobs = get_jobs()

if args['metric'] == "all" :
    args['metric'] = "longest_in_queue longest_build_duration queue_size jobsinprocess_size executors_stat reqexecutors"

if 'longest_in_queue' in args['metric']:
    send_data( args['server'], 'longest_in_queue', LongestInQueue(queue) )

if 'longest_build_duration' in args['metric']:
    for j in jobs:
        send_data( args['server'], 'longest_build_duration['+j['name']+']', get_longest_duration(j['url'], jobs_in_process) )

if 'queue_size' in args['metric']:
    # Number of task in process : Queue and InProcess
    send_data( args['server'], 'queue_size', len(queue) )

if 'jobsinprocess_size' in args['metric']:
    send_data( args['server'], 'jobsinprocess_size', len(jobs_in_process) )

if 'executors_stat' in args['metric']:
    # Send labels stat
    for l in JENKINSLABELS:
        url = "http://" + args["server"]+"/label/"+l+"/api/json"
        resp = session.get(url, timeout=REQ_TIMEOUT)
        executorsInfo = resp.json()
        curdata = {'busyExecutors['+l+']': executorsInfo['busyExecutors'], 'idleExecutors['+l+']': executorsInfo['idleExecutors']}
        send_dict( args['server'], curdata)

if 'reqexecutors' in args['metric']:
    discovery = []
    stat = {}
    for l in queue:
        try:
            stat['jobswaitlabel[{label}]'.format(label=str(l['required_label']))] += 1
            stat['TotalTimeInQueue[{label}]'.format(label=str(l['required_label']))] += l['queue_duration']/60
        except Exception as e:
            stat['jobswaitlabel[{label}]'.format(label=str(l['required_label']))] = 1
            stat['TotalTimeInQueue[{label}]'.format(label=str(l['required_label']))] = l['queue_duration']/60
            discovery.append({"{#NAME}": str(l['required_label'])})

    if int(time.strftime("%M")) % DISCOVERY_FREQ_M == 0 :
        send_data( args['server'], 'requiredlabels_discovery', json.dumps({"data": discovery}))

    send_dict( args['server'], stat)    


