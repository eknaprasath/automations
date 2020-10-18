#!/usr/bin/env python
import os
import boto3
from datetime import datetime, timedelta
from dateutil.tz import tzutc
from croniter import croniter
from concurrent.futures import ThreadPoolExecutor
SNS = boto3.client('sns')
sns_arn = os.environ['sns_arn']
region = os.environ['region_name']

def lambda_handler(event, context):
    print(region)
    auto_filter = [{
            'Name': 'tag:scheduler',
            'Values': ['scheduler_on']
        },
		{
		'Name': 'tag:scheduler_time',
        'Values': ['*']
		}
    ]

    try:
        print(f'-- Starting the Ec2 Scheduler')
        ec2 = boto3.resource('ec2', region_name=region)
        ec2client = boto3.client('ec2')
        now = datetime.now(tzutc())
        instance_list = ec2.instances.filter(Filters=auto_filter)
        #print(instance_list)
        start_list = []
        stop_list = []
        

        for instance in instance_list:
            try:
                auto_tag = [tag['Value'].split('/') for tag in instance.tags if tag['Key'] == 'scheduler_time'][0]
                auto_items = phrase(auto_tag)
                cron = dict()
                #print(instance.id)
                
                for action in ['start', 'stop']:
                    try:
                        cron[action] = (croniter(auto_items[action], now) if action in auto_items else False)
                    except Exception as err:
                        print(f'-- Invalid {action} cron value for {instance.id} : {err}')
                        cron[action] = False

                if cron['start'] and instance.state['Name'] == 'stopped' and now <= cron['start'].get_next(datetime) <= now + timedelta(0, 600):
                    try:
                        print(f'-- Starting {instance.id} based on schedule: {auto_items["start"]}')
                        #instance.start()
                        before = ec2client.describe_instances(InstanceIds=[instance.id],)
                        print(before)
                        response = ec2client.start_instances(InstanceIds=[instance.id],)
                        print(response)
                        after = ec2client.describe_instances(InstanceIds=[instance.id],)
                        print(after)
                        start_list.append(instance.id)
                    except Exception as err:
                        print(f'Error starting {instance.id} : {err}')
                        sendmail = SNS.publish(TopicArn=sns_arn,
                        Message='Error occured while starting the instance in Non-Production'+':'+'\n \n \t \t'+ instance.id,
                        Subject='Error-Resource scheduler !',
                        MessageStructure='string',
                        )

                elif cron['stop'] and instance.state['Name'] == 'running'  and now - timedelta(0, 600) <= cron['stop'].get_prev(datetime) <= now:
                    try:
                        print(f'Stopping {instance.id} based on schedule: {auto_items["stop"]}')
                        instance.stop()
                        stop_list.append(instance.id)
                    except Exception as err:
                        print(f'-- Error stopping {instance.id} : {err}')
                        sendmail = SNS.publish(TopicArn=sns_arn,
                        Message='Error occured while stopping the instance in Non-Production'+':'+'\n \n \t \t'+ instance.id,
                        Subject='Error-Resource scheduler !',
                        MessageStructure='string',
                        )

            except Exception as err:
                print(f'-- Error processing instance {instance.id} : {err}')
                sendmail = SNS.publish(TopicArn=sns_arn,
                Message='Error processing instance in Non-Production'+':'+'\n \n \t \t'+ instance.id,
                Subject='Error-Resource scheduler !',
                MessageStructure='string',
                )
        if len(start_list) > 0:
            sendmail = SNS.publish(TopicArn=sns_arn,
            Message='The following instances have been started in Non-Production'+':'+'\n \n \t \t'+'\n \n \t \t'.join(map(str, start_list)),
            Subject='Resource scheduler',
            MessageStructure='string',
            )
            print(start_list)
        else:
            print("No instance started")
        if len(stop_list) > 0:
            sendmail = SNS.publish(TopicArn=sns_arn,
            Message='The following instances have been stopped in Non-Production'+':'+'\n \n \t \t'+'\n \n \t \t'.join(map(str, stop_list)),
            Subject='Resource scheduler !',
            MessageStructure='string',
            )
            print(stop_list)
        else:
            print("No instance stopped")
    except Exception as err:
        print(f'Error in starting the scheduler: {err}')
        
# The below function is used to convert the tag in to cron expression

def phrase(auto_tag):
    
    auto_split = dict(item.split('=') for item in auto_tag if '=' in item)
    starting = auto_split['start'].split(' ')
    stopping = auto_split['stop'].split(' ')
    allowed_start = ['start',]
    allowed_stop = ['stop',]
    starting.insert(2,'*')
    starting.insert(2,'*')
    stopping.insert(2,'*')
    stopping.insert(2,'*')
    seperator = ' '
    dictstart = [seperator.join(starting)]
    dictstop = [seperator.join(stopping)]
    start_value = dict(zip(allowed_start, dictstart))
    stop_value = dict(zip(allowed_stop, dictstop))
    auto_item = {**start_value, **stop_value}
    #print(auto_item)
    return(auto_item)
        
