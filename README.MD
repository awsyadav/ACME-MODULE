# ACME CLOUD -Generic Module
How to use a ACME TERRAFORM function to DEPLOY the AWS Resource.

# Short Description
When a new instance is created, whether it is created on the web console, using the CLI or one of the AWS SDKs or through terraform, they will be created with at least one EBS volume (except for instance store instances) and one network interface, however the API call CreateTags will not propagate the tags to these dependent resources. To resolve this problem, we are going to use CloudWatch Events and Lambda to detect when instance tags are modified and then automatically tag the EBS volumes and ENIs that are attached to the instance.
We are going to take advantage a feature of CloudWatch Events that can trigger events every time an EC2 API call is invoked and specifically we will trigger it when CreateTags is invoked by an IAM user or a role and then forward the event to Lambda, Lambda will then check if the tagged resources were instances and if they are, since the event will contain the instance ids, we can use the event information to tag the EBS volumes and the ENIs attached to the instance.

# Resolution
In order to use this module clone the repository on your local system 

# Pre-Requisites
* Runtime: HCL, Terraform version 11.4
* Role with permissions to log to access the AWS Environment
* Memory: 128MB
* Timeout: 10 seconds

When creating the Terraform function, select Edit code inline and use the *Addtag.py*

For the IAM role select create a custom role and then on the role creation page select Create a new IAM Role with name lambda_ec2_tagging and update the policy document with this policy:

Then complete the creation of the function and go to the CloudWatch Events console, this can be located in the CloudWatch console under Events -> Rules and the steps are:
1.	Select Create Rule
2.	Select Build event pattern to match events by service
3.	Service Name: EC2
4.	Event Type: AWS API Call via CloudTrail
5.	Select Specific operation(s)
6.	Select CreateTags
7.	Select Add target
8.	Select Lambda function
9.	Function: tag_ec2_dependencies (or the name of the function if you used a different name)
10.	We leave version alias and input in their default values
11.	Select Configure details
12.	Give a name to the rule: tag_ec2_dependencies
13.	Add a description
14.	State: enabled
