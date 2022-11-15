# README

Help Deployment Automation Using Robot Framework

## Development Guide

### Environments
JENKINS_USER    default: admin
JENKINS_PASS    
BRANCH_VERSION  4.8.dev

HELP_USER   default: parisadmin
STAGING_URL     https://help.staging.noriasaas.no/index.php
STAGING_PASS
MIGRATION_URL       https://mig.help.staging.noriasaas.no/index.php
MIGRATION_PASS      

### Run the robot:

```
robot --report NONE --outputdir reports --logtitle "Automated Help Deployment" tasks.robot
```

## Build and Run Image
```
docker build -t help-robot .
```

### Run Image

```
docker run -it --rm help-robot bash
```


```
docker run -it --rm --network=host -v "$PWD/reports:/reports" --name help-container help-robot bash
```