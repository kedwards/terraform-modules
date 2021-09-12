#!/usr/bin/env bash -ex

ips=""
ids=""
while [ "$ids" = "" ]; do
  ids=$(aws-vault exec power -- autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG --region $REGION --query AutoScalingGroups[].Instances[].InstanceId --output text)
  sleep 1
done
for ID in $ids;
do
    IP=$(aws-vault exec power -- ec2 describe-instances --instance-ids $ID --region $REGION --query Reservations[].Instances[].PrivateIpAddress --output text)
    ips="$ips,$IP"
done