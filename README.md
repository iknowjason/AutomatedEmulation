# Automated Emulation Lab

## Overview

Automated Emulation Lab is a simple terraform template creating a customizable and automated Breach and Attack Simulation lab.  It automically builds the following resources hosted in AWS:

* One Linux server deploying Caldera, Prelude Operator Headless, VECTR services
* One Windows Client (Windows Server 2022 DC) auto-configured for Caldera agent deployment, Prelude pneuma, and other Red/Blue tools

See the **Features and Capabilities** section for more details.

## Key Differences

This lab differs from other popular ```Cyber Ranges``` in its design and philosophy.  No secondary tools like Ansible are necessary.  Feel free to use them if you like.  But they aren't required for configuration management.  Instead of using 3rd party configuration management tools, this lab uses terraform providers (AWS SDK) and builtin AWS features (```user data```).  You don't have to rely on a secondary agent or deal with outdated libraries or networking issues with agentless push or updating a secondary tool that causes issues over time.  This increases ```stability, consistency, and speed``` for building and configuring cloud resources.  Use terraform, bash, and powershell to build and configure.  A small user-data script is pushed into the system and runs.  Individual configuration management scripts are uploaded to an S3 bucket.  The master script instructs the system which smaller scripts to run which builds the system.  With good documentation, the location of these scripts should make it easy to add and customize.  See the **Features and Capabilities** section for more details.     

## Requirements and Setup

Tested with:
* Mac OS 13.4
* terraform 1.5.7

Clone this repository:
```
git clone https://github.com/iknowjason/AutomatedEmulation
```

Credentials Setup:

Generate an IAM programmatic access key that has permissions to build resources in your AWS account.  Setup your .env to load these environment variables.  You can also use the direnv tool to hook into your shell and populate the .envrc.  Should look something like this in your .env or .envrc:

```
export AWS_ACCESS_KEY_ID="VALUE"
export AWS_SECRET_ACCESS_KEY="VALUE"
```

## Build and Destroy Resources

### Run terraform init
Change into the AutomatedEmulation working directory and type:

```
terraform init
```

### Run terraform plan or apply
```
terraform apply -auto-approve
```
or
```
terraform plan -out=run.plan
terraform apply run.plan
```

### Destroy resources
```
terraform destroy -auto-approve
```

### View terraform created resources
The lab has been created with important terraform outputs showing services, endpoints, IP addresses, and credentials.  To view them:
```
terraform output
```

## Features and Capabilities

### Important Firewall and White Listing

### Caldera

### Prelude

### VECTR

### Red Tools

### Blue Tools

### 
