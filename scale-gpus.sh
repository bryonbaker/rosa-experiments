#! /bin/bash

echo "Scaling GPU machines to $1"
rosa edit machinepool --cluster 2a2lhe5sp73lrhascs8obmei2oq59imt --profile=rosa-6wlrc --region=ap-southeast-1 --replicas=$1 gpu-machinepool

rosa list machinepool --cluster 2a2lhe5sp73lrhascs8obmei2oq59imt --profile=rosa-6wlrc --region=ap-southeast-1
