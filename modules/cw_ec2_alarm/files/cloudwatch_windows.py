import boto3
import json
import os

ec2 = boto3.resource('ec2')
cw = boto3.client('cloudwatch')
#ec2_sns = 'arn:aws:sns:eu-west-1:XXXXXXXX:Topic'
ec2_sns = os.environ['sns_arn']
cpu_threshold =  os.environ['cw_cpu_threshold']
memory_threshold =  os.environ['cw_memory_threshold']
disk_threshold = os.environ['cw_disk_threshold']

def lambda_handler(event, context):
    
    print("Received event: " + json.dumps(event, indent=2))
    
    print(type(event['Blockdevice']))
    ec2 = boto3.resource('ec2')
    instance = ec2.Instance(event['instanceid'])
    id = instance.id
    cw = boto3.client('cloudwatch')
    if not instance.tags:
        instance_name = id
        print("No tags found")
    else:
        for tag in instance.tags:
            print(tag['Key'])
            if tag['Key'] == 'Name':
                instance_name = tag['Value']
    if type(event['Blockdevice'])==dict:
        size = 100 - int(disk_threshold)
        cw.put_metric_alarm(AlarmName= "Ec2 "+(instance_name) + " Available_DiskSpace below "+ str(size)+"%"+" in " + event['Blockdevice']['DeviceID'] ,
        AlarmDescription='DiskSpaceUtilization ',
        ActionsEnabled=True,
        AlarmActions=[ec2_sns,],
        MetricName='LogicalDisk % Free Space',
        Namespace='CWAgent',
        Statistic='Average',
        Period=300,
        EvaluationPeriods=1,
        Threshold=float(size),
        ComparisonOperator='LessThanOrEqualToThreshold',
        Dimensions =[{'Name': 'instance', 'Value': event['Blockdevice']['DeviceID']},
        {'Name': 'InstanceId', 'Value': id},
        {'Name': 'objectname', 'Value': "LogicalDisk"}],)
    else:
        size = 100 - int(disk_threshold)
        for blocks in event['Blockdevice']:
            cw.put_metric_alarm(AlarmName= "Ec2 "+(instance_name) + " Available_DiskSpace below "+ str(size)+"%"+" in " + blocks['DeviceID'] ,
        AlarmDescription='DiskSpaceUtilization ',
        ActionsEnabled=True,
        AlarmActions=[ec2_sns,],
        MetricName='LogicalDisk % Free Space',
        Namespace='CWAgent',
        Statistic='Average',
        Period=300,
        EvaluationPeriods=1,
        Threshold=float(size),
        ComparisonOperator='LessThanOrEqualToThreshold',
        Dimensions =[{'Name': 'instance', 'Value': blocks['DeviceID']},
        {'Name': 'InstanceId', 'Value': id},
        {'Name': 'objectname', 'Value': "LogicalDisk"}],)
                
    cw.put_metric_alarm(AlarmName = "Ec2 "+(instance_name) + " CPU utilization above " +str(cpu_threshold) + "%",
    AlarmDescription='CPU Utilization ',
    ActionsEnabled=True,
    AlarmActions=[ec2_sns,],
    MetricName='CPUUtilization',
    Namespace='AWS/EC2',
    Statistic='Average',
    Dimensions=[ {'Name': "InstanceId",'Value': id},],
    Period=300,
    EvaluationPeriods=1,
    Threshold=float(cpu_threshold),
    ComparisonOperator='GreaterThanOrEqualToThreshold')
    cw.put_metric_alarm(AlarmName = "Ec2 "+(instance_name) + " status check has failed",
    AlarmDescription='status check failure',
    ActionsEnabled=True,
    AlarmActions=[ec2_sns],
    MetricName='StatusCheckFailed',
    Namespace='AWS/EC2',
    Statistic='Average',
    Dimensions=[ {'Name': "InstanceId",'Value': id},],
    Period=60,
    EvaluationPeriods=1,
    Threshold=1.0,
    ComparisonOperator='GreaterThanOrEqualToThreshold')
    cw.put_metric_alarm(AlarmName = "Ec2 "+(instance_name) + " memory utilization above "+str(memory_threshold)+"%",
    AlarmDescription='High Memory Utilization',
    ActionsEnabled=True,
    AlarmActions=[ec2_sns],
    MetricName='Memory % Committed Bytes In Use',
    Namespace='CWAgent',
    Statistic='Average',
    Dimensions=[ {'Name': "InstanceId",'Value': id},{'Name': 'objectname', 'Value': "Memory"}],
    Period=300,
    EvaluationPeriods=1,
    Threshold=float(memory_threshold),
    ComparisonOperator='GreaterThanOrEqualToThreshold')