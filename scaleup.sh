#!/bin/bash
# run this in the morning to set the shared resources to 1 rs
namespace=( $(cat ./shared.txt) )
IFS='\n' read -r -a array <<< "$namespace"

for n in ${namespace[@]}; do
  deployments_array=( $(kubectl get deployments --no-headers -o custom-columns=":metadata.name" -n $n) )
  IFS='\n' read -r -a array <<< "$deployments_array"
  for d in ${deployments_array[@]}; do
    echo $n $d
    $(kubectl scale deployments $d -n $n --replicas=1)    
  done
done 
