*** Settings ***
Library     String

Resource    jenkins-page.robot
Resource    jenkins-dom.robot
Resource    help-backoffice-page.robot


*** Variables ***
# Jenkins Credentials
${JENKINS_USER}        admin
${JENKINS_PASS}        fromCMD
${BRANCH_VERSION}         4.8.dev


${HELP_USER}     parisadmin
${STAGING_URL}      https://help.staging.noriasaas.no/index.php
${STAGING_PASS}    fromCMD
${MIGRATION_URL}      https://mig.help.staging.noriasaas.no/index.php
${MIGRATION_PASS}     fromCMD

*** Tasks ***
Build The Image From Branch ${BRANCH_VERSION}
    [Headless] Login To Jenkins    ${JENKINS_USER}    ${JENKINS_PASS}
    GoTo Specific Branch    ${BRANCH_VERSION}
    [Headless] Build Images For Specific Branch    ${BRANCH_VERSION}
    ${BuildNo}=     Get Latest Build Number
    Set Global Variable    ${latestBuildNo}   ${BuildNo} 
    [Headless] Waiting For Build Success
    
Deploy to HELP-MIGRATION server
    ${option}=     Set Variable    help-test
    [Headless] Deploy Specific Help Server     ${option}
    [Headless] Waiting For Build Success

Deploy to HELP-MIGRATION server
    ${option}=     Set Variable    help-mig
    [Headless] Deploy Specific Help Server     ${option}
    [Headless] Waiting For Build Success

Verify Build for HELP-TEST BackOffice
    Log Into BackOffice     ${STAGING_URL}     ${HELP_USER}     ${STAGING_PASS} 
    Go To System Infor Page
    Verify Build Number From System Info Page    ${latestBuildNo}

Verify Build for HELP-MIGRATION BackOffice
    Log Into BackOffice     ${MIGRATION_URL}     ${HELP_USER}     ${MIGRATION_PASS} 
    Go To System Infor Page
    Verify Build Number From System Info Page    ${latestBuildNo}