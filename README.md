# Operator Lab 

Operator Lab is a security lab enabling Red and Blue teams to improve offensive and defensive capabilities.  This documentation is a work in progress and will be updated further.

## Overview

## Features and Capabilities

## Installation

Tested with:
* Mac OS 13.4
* python 3.9
* terraform 1.5.7

Extra requirements:
Faker:  ```pip3 install faker```

Credentials Setup:
Generate an IAM programmatic access key that has permissions to build resources in your AWS account.  Setup your .env to load these environment variables.  You can also use the direnv tool to hook into your shell and populate the .envrc.  Should look something like this in your .env or .envrc:
```
export AWS_ACCESS_KEY_ID="VALUE"
export AWS_SECRET_ACCESS_KEY="VALUE"
```

## Usage Examples

The basic usage is like this:  
1. Run operator:  ```python3 operator.py <OPTIONS>```.  This will generate terraform files.  Then run terraform.
2. ```terraform init```
3. ```terraform apply -auto-approve```

**Destroy:** When you are finished and wish to destroy the resources:  ```terraform destroy -auto-approve```

### Build Windows Client Systems
```python3 operator.py --winclient 1```

Description:  Builds one Windows Server 2022 clients instrumented with Sysmon, Atomic Red Team, and PurpleSharp.

```python3 operator.py --winclient 1 --region us-west-1```

Description:  Same as above, but builds all resources in us-west-1 instead of default region (us-east-2)

### Install Nomad
```python3 operator.py --winclient 1 --nomad```

Description:  Installs a Nomad cluster and installs the nomad client on each windows client system.  Nomad jobs can be pushed to clients.  This allows red team automation and orchestration of chaining TTPs across nomad clients.  The ```jobs``` directory contains an example ping command that is pushed to all clients.  A library of different job files can be developed to automate Red Team TTPs.

Reference:  https://www.nomadproject.io/

### Install Ghosts NPC
```python3 operator.py --winclient 1 --ghosts```

Description:  Installs the Ghosts NPC (Non-player Character) framework.  This creates a GHOSTS server with Grafana dashboards and API.  For each Windows client, they automatically install the Ghosts client and register to the Ghosts API server.  

Reference:  https://github.com/cmu-sei/GHOSTS

### Install Breach and Attack Simulation (Caldera, VECTR, Prelude Operator)
```python3 operator.py --winclient 1 --ghosts```

Description:  Installs a Breach and Attack Simulation Linux server.  The server installs Caldera, VECTR.  For each Windows client, Prelude Operator GUI is installed automatically.  

Note:  Still need to install the prelude headless pneuma for remote C2 control of the windows clients.

Reference:  https://github.com/SecurityRiskAdvisors/VECTR

### Install SIEM (Splunk, Elastic)
```python3 operator.py --winclient 1 --siem [elk|splunk]```

Description:  Installs either Elasticsearch with Kibana or a Splunk Enterprise linux server.  Each windows client automatically installs and ships elastic logs via winlogbeat.

Note:  The Splunk system is incomplete.  It installs the server software and bootstraps the service.  Still need to load some indexes and dashboards.  Still need to have windows clients install the universal forwarder and ship logs to Splunk fully automated.

## To Do List

- [x] Use jinja templates for terraform instrumented with python ✅ 2023-07-25
- [x] Test install_red script to get Atomic Red Team, PurpleSharp installed ✅ 2023-07-25
- [x] Test sysmon install scripts on windows ✅ 2023-07-25
- [ ] Build DC and Domain Join support on endpoints
- [ ] Test Windows auto logon domain users using domain credentials
- [x] Nomad cluster / orchestration of red teaming (Wed) ✅ 2023-07-27
- [x] BAS (Breach and Attack Simulation) box with Caldera Prelude Operator + VECTR ✅ 2023-08-25
- [x] SIEM support (ELK) + winlogbeat log forwarding ✅ 2023-08-25
- [ ] SIEM support (Splunk)
- [ ] CloudWatch agent ship logs to S3 bucket
- [ ] Ship logs to S3 bucket instead of SIEM, using EC2 agent
- [x] Ghosts NPC User Simulation ✅ 2023-08-25
- [ ] Prelude Operator headless C2 setup with pneuma
- [ ] Velociraptor server and endpoints
- [ ] C2 support
- [ ] Cloudtrail auditing and store in s3
- [ ] Mac system support
- [ ] linux system support
- [ ] Infection monkey
- [ ] Adversary system (Kali Linux or RedCloud OS)

