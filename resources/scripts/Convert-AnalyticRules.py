#!/usr/bin/env python3

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# References:
# https://stackoverflow.com/questions/38620471/json-dumps-u-escaped-unicode-to-utf8

import glob
import json
import yaml
import argparse
import os
from tqdm import tqdm
from time import sleep
import sys
import logging

# Initial description
text = "This script translates analytic rules from https://github.com/Azure/Azure-Sentinel/tree/master/Detections to JSON files"
example_text = f'''examples:

 python3 {sys.argv[0]} -f detections/SecurityEvent/ExcessiveLogonFailures.yaml -o folder/
 python3 {sys.argv[0]} -f detections/ -o folder/
 '''

# Initiate the parser
parser = argparse.ArgumentParser(description=text,epilog=example_text,formatter_class=argparse.RawDescriptionHelpFormatter)

# Add arguments (store_true means no argument needed)
parser.add_argument('-f', "--file-path", nargs='+', help="Path of YAML file(s) or folder(s) of YAML files", required=True)
parser.add_argument('-o', "--output-path", type=str , help="Folder path to output JSON files", required=True)
parser.add_argument("-d", "--debug", help="Print lots of debugging statements", action="store_const", dest="loglevel", const=logging.DEBUG, default=logging.WARNING)
parser.add_argument("-v", "--verbose", help="Be verbose", action="store_const", dest="loglevel", const=logging.INFO)

args = parser.parse_args()

logging.basicConfig(level=args.loglevel)
log = logging.getLogger(__name__)

# Set output path
output_path = os.path.abspath(args.output_path)

# Aggregate files from Input Paths
input_paths = [os.path.abspath(path) for path in args.file_path]

all_files = []
for path in input_paths:
    if os.path.isfile(path):
        all_files.append(path)
    elif os.path.isdir(path):
        all_files = glob.glob(f"{path}/**/*.yaml", recursive=True)
    else:
        quit()

# Initializing outer progress bar and file POST response
outer = tqdm(total=len(all_files), desc='Files', position=0)

# Initialize All AnalytucRules list
allAnalyticRules = list()

# Proces all JSON File(s)
for analytic in all_files:
    log.info(f'Started to process {analytic}')
    
    analytic_filename = os.path.splitext(os.path.basename(analytic))[0]
    analytic_folder=os.path.dirname(analytic)
    analytic_folder_name=os.path.basename(analytic_folder)

    # Create folder if it does not exists
    os.makedirs(f'{output_path}/{analytic_folder_name}', exist_ok=True)

    analytic_load = yaml.safe_load(open(analytic).read())

    # Removing key 'id'
    analytic_load.pop("id", None)

    # Updating key 'name' to Key 'displayName'
    analytic_load['displayName'] = analytic_load.pop('name')

    # Enabling Rule by adding key 'enabled'
    analytic_load['enabled'] = True

    # Transforming string to ISO_8601 format
    # References:
    # https://en.wikipedia.org/wiki/ISO_8601
    # PdDThHmMsS, where d, h, m, and s are digit sequences for the number of days, hours, minutes, and seconds, respectively. For example: "P0DT06H23M34S".
    queryFrequency = analytic_load['queryFrequency'].upper()
    queryPeriod = analytic_load['queryPeriod'].upper()
    if "D" in queryFrequency:
        analytic_load['queryFrequency'] = f'P{queryFrequency}'
    if "H" in queryFrequency:
        analytic_load['queryFrequency'] = f'PT{queryFrequency}'
    if "M" in queryFrequency:
        analytic_load['queryFrequency'] = f'PT{queryFrequency}'
    if "D" in queryPeriod:
        analytic_load['queryPeriod'] = f'P{queryPeriod}'
    if "H" in queryPeriod:
        analytic_load['queryPeriod'] = f'PT{queryPeriod}'
    if "M" in queryPeriod:
        analytic_load['queryPeriod'] = f'PT{queryPeriod}'
    
    # Converting TriggerOperator key value 'gt' to type 'Microsoft.Azure.Sentinel.Analytics.Management.AnalyticsManagement.Contracts.Model.AlertTriggerOperator'
    if "gt" in analytic_load['triggerOperator']:
        analytic_load['triggerOperator'] = "GreaterThan"
    
    # Adding suppressionDuration to alert
    analytic_load['suppressionDuration'] = "PT5H"
    analytic_load['suppressionEnabled'] = False
    
    # Adding Rule template to API Scheduled format
    analytic_dict = dict()
    analytic_dict['kind'] = 'Scheduled'
    analytic_dict['properties'] = analytic_load

    # write to file
    with open(f'{output_path}/{analytic_folder_name}/{analytic_filename}.json', 'w') as f:
        f.write(json.dumps(analytic_dict, indent=4))
    
    # Add to All AnalyticRules list
    allAnalyticRules.append(analytic_dict)
    outer.update(1)

# write allAnalyticRule to allAnalyticRules.json
with open(f'{output_path}/allAnalyticRules.json', 'w') as f:
    f.write(json.dumps(allAnalyticRules, indent=4))