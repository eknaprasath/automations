import boto3
import os
import json

SNS = boto3.client('sns')
EC2 = boto3.client('ec2')
RDS = boto3.client('rds')
ALB = boto3.client('elbv2')

tag1Key = os.environ['tag1Key']
tag2Key = os.environ['tag2Key']
tag3Key = os.environ['tag3Key']
tag4Key = os.environ['tag4Key']
tag5Key = os.environ['tag5Key']
tag6Key = os.environ['tag6Key']
man_tag = os.environ['tag7Key']
man_tag_1 = os.environ['tag8Key']

tag1Value = os.environ['tag1Value']
tag2Value = os.environ['tag2Value']
tag3Value = os.environ['tag3Value']
tag4Value = os.environ['tag4Value']
tag5Value = os.environ['tag5Value']
tag6Value = os.environ['tag6Value']
man_tag_val = os.environ['tag7Value']
man_tag_val_1 = os.environ['tag8Value']

#man_tag = "BusinessService"
#man_tag_val = "123"

keys = []
db_keys = []
snap_keys = []
alb_keys = []

def get_resources_from(compliance_details):
    results = compliance_details['EvaluationResults']
    resources = [result['EvaluationResultIdentifier']['EvaluationResultQualifier'] for result in results]
    next_token = compliance_details.get('NextToken', None)

    return resources, next_token

def lambda_handler(event, context):
    config = boto3.client('config')

    next_token = ''
    next_token_1 = ''
    resources = []
    resourcelist = []
    resourcetypelst = []
    tag_value = [{'Key': tag1Key, 'Value': tag1Value},{'Key': tag2Key, 'Value': tag2Value},{'Key': tag3Key, 'Value': tag3Value},{'Key': tag4Key, 'Value': tag4Value},{'Key': tag5Key, 'Value': tag5Value},{'Key': tag6Key, 'Value': tag6Value},]
 #   tag_value_1 = [{'Key': tag7Key, 'Value': tag7Value},]
    
    #print("Received event: " + json.dumps(event, indent=2))

    while next_token is not None:
        compliance_details = config.get_compliance_details_by_config_rule(
            ConfigRuleName='required-tags-1',
            ComplianceTypes=['NON_COMPLIANT'],
            Limit=100,
            NextToken=next_token
            )
        #print(compliance_details)

        current_batch, next_token = get_resources_from(compliance_details)
        resources += current_batch
        valuefromdict = compliance_details['EvaluationResults']
        #print(valuefromdict)
        for values in valuefromdict:
        	resourceid = values['EvaluationResultIdentifier']['EvaluationResultQualifier']['ResourceId']
        	resourcetype = values['EvaluationResultIdentifier']['EvaluationResultQualifier']['ResourceType']
        	resourcelist.append(resourceid)
        	resourcetypelst.append(resourcetype)

        	
    for resource_type, resource_name in zip(resourcetypelst, resourcelist):
        	if resource_type == 'AWS::EC2::Instance':
        	    print("The ec2 instance to be tagged is ", resource_name)
        	    response = EC2.create_tags(Resources=[resource_name],Tags=tag_value)
        	elif resource_type == 'AWS::RDS::DBInstance':
        	    
        	    describe_db = RDS.describe_db_instances(
        	        Filters=[
                                  {
                                  'Name': 'dbi-resource-id',
                                  'Values': [resource_name,]
                                      
                                  },
                                  ],
                               )
        	    for i in describe_db['DBInstances'] :
        	         #print(i)
        	         response = RDS.add_tags_to_resource(ResourceName=i['DBInstanceArn'],Tags=tag_value)
        	         print("The RDS instance to be tagged is ", i['DBInstanceIdentifier'])
        	elif resource_type == 'AWS::RDS::DBSnapshot':
        	    print("The RDS Snapshot to be tagged is ", resource_name)
        	    describe_snapshot = RDS.describe_db_snapshots(DBSnapshotIdentifier=resource_name,)
        	    data= describe_snapshot['DBSnapshots']
        	    #print(data)
        	    for i in data:
        	        snap_arn = i['DBSnapshotArn']
        	        response = RDS.add_tags_to_resource(ResourceName=snap_arn,Tags=tag_value)
        	elif resource_type == 'AWS::ElasticLoadBalancingV2::LoadBalancer':
        	    print("The ALB to be tagged is ", resource_name)
        	    response = ALB.add_tags(ResourceArns=[resource_name],Tags=tag_value)  

    while next_token_1 is not None:
        compliance_details = config.get_compliance_details_by_config_rule(
            ConfigRuleName='required-tags-2',
            ComplianceTypes=['NON_COMPLIANT'],
            Limit=100,
            NextToken=next_token_1
            )
        print(compliance_details)

        current_batch, next_token_1 = get_resources_from(compliance_details)
        resources += current_batch
        valuefromdict = compliance_details['EvaluationResults']
        print(valuefromdict)
        for values in valuefromdict:
        	resourceid = values['EvaluationResultIdentifier']['EvaluationResultQualifier']['ResourceId']
        	resourcetype = values['EvaluationResultIdentifier']['EvaluationResultQualifier']['ResourceType']
        	resourcelist.append(resourceid)
        	resourcetypelst.append(resourcetype)

        	
    for resource_type, resource_name in zip(resourcetypelst, resourcelist):
        if resource_type == 'AWS::EC2::Instance':
        	print("The ec2 instance to be tagged is ", resource_name)
        	response = EC2.describe_instances(InstanceIds=[resource_name],).get('Reservations', [])
        	for instance in response:
        	    for insid in instance['Instances']:
        	        keys.clear()
        	        try:
        	            for ins in insid['Tags']:
        	                keys.append(ins['Key'])
        	        except:
        	            print('not_tags_available')
        	    print('ec2 tags',keys)
        	    if man_tag  not in keys:
        	        print('available')
        	        response = EC2.create_tags(Resources=[resource_name],Tags=[{'Key': man_tag,'Value': man_tag_val}],)
        	    if man_tag_1 not in keys:
        	        print('available')
        	        response = EC2.create_tags(Resources=[resource_name],Tags=[{'Key': man_tag_1,'Value': man_tag_val_1}],)

        	    
        elif resource_type == 'AWS::RDS::DBInstance':
            describe_db = RDS.describe_db_instances(
        	        Filters=[
                                  {
                                  'Name': 'dbi-resource-id',
                                  'Values': [resource_name,]
                                      
                                  },
                                  ],
                               )
            for i in describe_db['DBInstances']:
                instance_identi = i['DBInstanceArn']
                instance_id = i['DBInstanceIdentifier']
            tag = RDS.list_tags_for_resource(ResourceName= instance_identi,)
            print(tag['TagList'])
            for ins in tag['TagList']:
                db_keys.append(ins['Key'])
            print(instance_id, 'DB', db_keys)
            
            if man_tag not in db_keys:
                print(man_tag, 'not available')
                response = RDS.add_tags_to_resource(ResourceName=i['DBInstanceArn'],Tags=[{'Key': man_tag,'Value': man_tag_val}])
                print("The RDS instance ", man_tag , " added in ", instance_id)    
            
            if man_tag_1 not in db_keys:
                print(man_tag_1, 'not available')
                response = RDS.add_tags_to_resource(ResourceName=i['DBInstanceArn'],Tags=[{'Key': man_tag_1,'Value': man_tag_val_1}])
                print("The RDS instance ", man_tag_1 ," added in ", instance_id)
                
        elif resource_type == 'AWS::RDS::DBSnapshot':
           # print("The RDS Snapshot to be tagged is ", resource_name)
            describe_snapshot = RDS.describe_db_snapshots(DBSnapshotIdentifier=resource_name,)
            data= describe_snapshot['DBSnapshots']
            #print(data)
            for i in data:
                snap_arn = i['DBSnapshotArn']
                #response = RDS.add_tags_to_resource(ResourceName=snap_arn,Tags=tag_value_1)
                tag = RDS.list_tags_for_resource(ResourceName= snap_arn,)
                #print(tag['TagList'])
                snap_keys.clear()
                for ins in tag['TagList']:
                    snap_keys.append(ins['Key'])
                #print(resource_name, 'snapshot tags', snap_keys)
                if man_tag not in snap_keys:
                    print(man_tag, 'not available in DB snapshot')
                    response = RDS.add_tags_to_resource(ResourceName=snap_arn,Tags=[{'Key': man_tag,'Value': man_tag_val}])
                    print("The RDS instance ", man_tag , " added in ", resource_name)
                if man_tag_1 not in snap_keys:
                    print(man_tag_1, 'not available in DB snapshot')
                    response = RDS.add_tags_to_resource(ResourceName=snap_arn,Tags=[{'Key': man_tag_1,'Value': man_tag_val_1}])
                    print("The RDS instance ", man_tag_1 ," added in ", resource_name)
  
        elif resource_type == 'AWS::ElasticLoadBalancingV2::LoadBalancer':
            print("The ALB to be tagged is ", resource_name)

            #print(resource_name)
            response = ALB.describe_tags(ResourceArns=[resource_name]).get('TagDescriptions', [])
            #print(response)
            alb_keys.clear()
            for albtag in response:
                for tagkey in albtag['Tags']:
                    alb_keys.append(tagkey['Key'])
            print(alb_keys)
            if man_tag not in alb_keys:
                print(man_tag, 'not available in ALB')
                response = ALB.add_tags(ResourceArns=[resource_name],Tags=[{'Key': man_tag,'Value': man_tag_val}])
                print("The ALB instance ", man_tag , " added in ", resource_name)
            
            if man_tag_1 not in alb_keys:
                print(man_tag_1, 'not available in ALB')
                response = ALB.add_tags(ResourceArns=[resource_name],Tags=[{'Key': man_tag_1,'Value': man_tag_val_1}])
                print("The ALB instance ", man_tag_1 , " added in ", resource_name)
                
if __name__ == "__main__":
    main()
    
