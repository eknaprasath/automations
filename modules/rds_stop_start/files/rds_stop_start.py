import os
import boto3
from datetime import datetime, timedelta
from dateutil.tz import tzutc
from croniter import croniter
from concurrent.futures import ThreadPoolExecutor

client = boto3.client('rds')
response = client.describe_db_instances()
SNS = boto3.client('sns')
sns_arn = os.environ['sns_arn']
region = os.environ['region_name']

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
def lambda_handler(event, context):
   start_list = []
   stop_list = []
   now = datetime.now(tzutc())
   for i in response['DBInstances']:
        #print(i)
        db_instance_name = i['DBInstanceIdentifier']
        db_type = i['DBInstanceClass']
        db_storage = i['AllocatedStorage']
        db_engine = i['Engine']
        db_resourceid =  i['DbiResourceId']
        db_arn = i['DBInstanceArn']
        db_status = i['DBInstanceStatus']
        
        #print (db_instance_name,db_type,db_storage,db_engine,db_resourceid,db_arn)
        tag_list = client.list_tags_for_resource(ResourceName=db_arn,)
        #print(tag_list['TagList'])
        for tag in tag_list['TagList']:
           try:
              #print(tag)
              if tag['Key'] == 'scheduler_time':
                 value= tag['Value'].split('/')
                 #print(value)
                 auto_items = phrase(value)
                 #print(auto_items)
                 cron = dict()
                 
                 for action in ['start', 'stop']:
                    try:
                        cron[action] = (croniter(auto_items[action], now) if action in auto_items else False)
                    except Exception as err:
                        print(f'-- Invalid {action} cron value for {db_instance_name} : {err}')
                        cron[action] = False
                        
                        
                 if cron['start'] and db_status == 'stopped' and now <= cron['start'].get_next(datetime) <= now + timedelta(0, 600):
                     try:
                        print(f'-- Starting {db_instance_name} based on schedule: {auto_items["start"]}')
                        db_start = client.start_db_instance(DBInstanceIdentifier=db_instance_name)
                        print(db_start)
                        start_list.append(db_instance_name)
                     except Exception as err:
                        print(f'Error starting {db_instance_name} : {err}')
                        sendmail = SNS.publish(TopicArn=sns_arn,
                        Message='Error occured while starting the instance in Non-Production'+':'+'\n \n \t \t'+ db_instance_name +":"+ str(err),
                        Subject='Error-Resource scheduler !',
                        MessageStructure='string',
                        )

                 elif cron['stop'] and db_status == 'available'  and now - timedelta(0, 600) <= cron['stop'].get_prev(datetime) <= now:
                    try:
                        print(f'Stopping {db_instance_name} based on schedule: {auto_items["stop"]}')
                        db_stop = client.stop_db_instance(DBInstanceIdentifier=db_instance_name,)
                        stop_list.append(db_instance_name)
                    except Exception as err:
                        print(f'-- Error stopping {db_instance_name} : {err}')
                        sendmail = SNS.publish(TopicArn=sns_arn,
                        Message='Error occured while stopping the instance in Non-Production'+':'+'\n \n \t \t'+ db_instance_name +":"+ str(err),
                        Subject='Error-Resource scheduler !',
                        MessageStructure='string',
                        )
                        
           except Exception as err:
                print(f'-- Error processing instance {db_instance_name} : {err}')
                sendmail = SNS.publish(TopicArn=sns_arn,
                Message='Error processing instance in Non-Production'+':'+'\n \n \t \t'+ db_instance_name,
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