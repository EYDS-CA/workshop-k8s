#!/bin/bash
#run this at night to set all replicatsets to 0
namespace=( $(kubectl get ns --no-headers -o custom-columns=":metadata.name") )
IFS='\n' read -r -a array <<< "$namespace"

for n in ${namespace[@]}; do
  deployments_array=( $(kubectl get deployments --no-headers -o custom-columns=":metadata.name" -n $n) )
  IFS='\n' read -r -a array <<< "$deployments_array"
  for d in ${deployments_array[@]}; do
    echo $n $d
    $(kubectl scale deployments $d -n $n --replicas=0)    
  done
done 
