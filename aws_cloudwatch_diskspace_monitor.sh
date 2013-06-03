#!/bin/sh

# You can read the manual to understand this in my blog
# http://birkoff.net/blog/set-up-a-monitor-in-cloudwatch-amazon-aws/

export AWS_CLOUDWATCH_HOME=/home/user/monitoring/CloudWatch-1.0.12.1
export JAVA_HOME=/home/user/jdk
export AWS_CREDENTIAL_FILE=/home/user/monitoring/CloudWatch-1.0.12.1/credential-file

# setup entries in ~/.ssh/config
MACHINES="production1,production2,production3,qa1,qa2,qa3"

for m in $(echo $MACHINES | sed -n 1'p' | tr ',' '\n')
do

ssh $m "df -H | grep -vE '^Filesystem|tmpfs|cdrom'" | awk '{ print $5 " " $1 }' | while read output;
#df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo "$(date -u +\"%Y-%m-%dT%H:%M:%S.000Z\") $m : $output"
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  partition=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 10 ]; then
    echo "$(date -u +\"%Y-%m-%dT%H:%M:%S.000Z\") Running out of space \"$partition ($usep%)\" on $m as on $(date -u +\"%Y-%m-%dT%H:%M:%S.000Z\")"
    /home/user/monitoring/CloudWatch-1.0.12.1/bin/mon-put-data --metric-name disk-space-$m-$partition --namespace 'NRP EBS' --value $usep --timestamp $(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
    echo "$(date -u +\"%Y-%m-%dT%H:%M:%S.000Z\") /home/user/monitoring/CloudWatch-1.0.12.1/bin/mon-put-data --metric-name disk-space-$m-$partition --namespace 'NRP EBS' --value $usep --timestamp $(date -u +\"%Y-%m-%dT%H:%M:%S.000Z\")"
  fi
done

done
