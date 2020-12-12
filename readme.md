# Plex Media Server on AWS using Spot Instances and S3 for Media Storage

## Assumptions
 * You have Packer Installed
 * You have Terraform Installed
 * You have AWS CLI installed
 * Your default profile for AWS CLI is configured and that is what you'd like to use
 * You have a VPC Configured with a public subnet
   * NACLs: 32400 in, SSH in for your IP Address, HTTP/HTTPS, out, ephemeral port range of 	
1024 - 65535 in/out, Port 53 UDP Out for DNS (all needs verification)
 * You have an ssh key pair set up in AWS

## Deployment Steps

1. Run Packer to create your AMI
2. Run Terraform

## Packer

This Packer configuration will install the necearry software to run Plex Media Server in a Docker Container as well as s3fs-fuse which gives you the ability have a FUSE-based file system backed by Amazon S3.

* https://hub.docker.com/r/plexinc/pms-docker/
* https://github.com/s3fs-fuse/s3fs-fuse

### Running Packer

There are two different configurations, one for the x86 architecture and one for the ARM architecture.

Update the AMI name in the json file so it is unique by updating the suffix in the format of YYYYMMDD for the date.

After changing into the packer directory run one of the following commands to build your AMI:

x86:
```packer build .\plex-x86_64.json```

ARM:
```packer build .\plex-arm64.json```

## Modules

There are two modules, one for deploying your storage and one for deploying the rest of the resources required to run your Plex Meida Server.  This gives you the ability to easily tear down your Plex Media Server while keeping your storage.

### Plex Storage Module

This module will deploy the following:
* EBS Volume used for your Plex Media Server database
* S3 Bucket for each Media Library you plan to create

#### Input Parameters

|Parameter Name|Type|Description|
|--------------|----|-----------|
|environment|string|Name of your plex environment.  This will be used to uniqely name resources, so make sure your name fits into nameing standards for S3 buckets.|
|availability_zone|string|Availability zone to deploy your EBS volume.|
|plex_libraries|list|List of strings for each Media Library you would like to create|

#### Output Parameters

|Parameter Name|Description|
|--------------|-----------|
|s3_buckets|List of objects representing the S3 buckets created for your Media Libraries.  This will be used for inputs to the Plex Media Server module.|
|ebs_volume|Object representing the EBS Volume for you Plex Media Server databasse.  This will be used for inputs to the Plex Media Server module.| 

### Plex Media Server Module

#### Input Parameters

|Parameter Name|Type|Description|
|--------------|----|-----------|
|environment|string|Name of your plex environment.  This will be used to uniqely name resources.  This should match the environment name you used for the storage module.|
|ssh_key_name|string|Name of ssh key to ssh to ec2 instance.|
|vpc_id|string|ID of your exising VPC|
|subnet_id|string|ID of the subnet to deploy your ec2 instance.|
|availability_zone|string|Availability zone of your subnet.|
|my_ip|string|Your IP Address.  Used for security groups to allow traffic from only you.|
|plex_claim_token|string|Claim token for your Plex Server (see below)|
|s3_buckets|list|S3 Bucket Output from the Storage Module.|
|ebs_volume|object|EBS Volume output from Storage Module.|
|instance_types|list|List of Instance Types you would like to use.  The Auto Scaling group uses a mixed instance policy, so you can specify multiple instance types in case there is no capacity available for the instance type you prefer.  This is particularly helpful for spot instances.|
|sns_email_address|string|Email Address for receiving SNS Notifications.|
|architecture|string|CPU Architecuture.  Valid values are x86_64 and arm64.  Default is x86_64.|
|spot|bool|Boolean for whether you'd like to use spot instances or not.|

## Setting up your Terraform to use the Module

Set the following variables in the terraform.tfvars file:

|Parameter Name|Type|Description|
|--------------|----|-----------|
|environment|string|Name of your plex environment.  This will be used to uniqely name resources.  This should match the environment name you used for the storage module.|
|ssh_key_name|string|Name of ssh key to ssh to ec2 instance.|
|vpc_id|string|ID of your exising VPC|
|subnet_id|string|ID of the subnet to deploy your ec2 instance.|
|availability_zone|string|Availability zone of your subnet.|
|my_ip|string|Your IP Address.  Used for security groups to allow traffic from only you.|
|plex_claim_token|string|Claim token for your Plex Server (see below)|
|plex_libraries|list|List of Plex Libraries|
|instance_types|list|List of Instance Types you would like to use.  The Auto Scaling group uses a mixed instance policy, so you can specify multiple instance types in case there is no capacity available for the instance type you prefer.  This is particularly helpful for spot instances.|
|sns_email_address|string|Email Address for receiving SNS Notifications.|
|architecture|string|CPU Architecuture.  Valid values are x86_64 and arm64.  Default is x86_64.|
|spot|bool|Boolean for whether you'd like to use spot instances or not.|

## Plex Claim Token

Get Plex Claim Token: https://www.plex.tv/claim

The Claim Token is only good for a few minutes, so it is easiest to not set this variable and let Terraform prompt you for it.

## Running Terraform

First, make sure you've run `terraform init` on your repo.

Then run `terraform plan` and if it is going to do what you expect run `terraform apply`.

## After your server is done spinning up

### If the plex app cannot connect to your server

* Go to http://{ip}:32400/web
* Settings -> Remote Access -> Enable Remote Access
    * Check Specify Port (leave the port the same) and retry

### Create Libraries

* Go to Manage -> Libraries
    * Create libraries seleting folders within the /plex-data folder

### Minimize EBS and S3 API Requests to Reduce Cost

To avoid scanning of the files in the S3 bucket (meaning additional S3 api requests and additional EBS i/o requests -> additional cost)
 * Don't set Plex to periodically scan library
 * Turn off scheduled tasks that will scan the library - I leave on the following
   * Backup database every three days
   * Optimize database every week
   * Remove old bundles every week
   * Remove old cache files every week
   * Upgrade media analysis during maintenance