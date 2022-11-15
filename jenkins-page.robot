*** Settings ***
Documentation     Simple example using SeleniumLibrary.
Library         SeleniumLibrary
Library    String

*** Variables ***
${BASE_URL}      https://build.noriacloud.com/jenkins
${BROWSER}        Chrome

${HELP_STAGING_URL}             /job/Tools/job/ContinuousDelivery/job/help-staging/build


########################## LOCATORS #######################################
${LOGINPAGE_USERNAME_TEXT}        id:j_username
${LOGINPAGE_PASSWORD_TEXT}        //input[@name='j_password']
${LOGINPAGE_SUBMIT_BTN}         //button[@name='Submit']

${BRANCHPAGE_DRYRUN_CHBOX}        //span[@class='jenkins-checkbox']/label[contains(text(),'DRY_RUN')]/preceding-sibling::input
${BRANCHPAGE_DRYRUN_LABEL}        //span[@class='jenkins-checkbox']/label[contains(text(),'DRY_RUN')]
${BRANCHPAGE_BUILD_BTN}         //button[@type='submit']
${BRANCHPAGE_LATEST_BUILD_NO}         //div[@id='buildHistory']//div[@class='row pane-content']//tr[@page-entry-id][1]//a[contains(@class,'display-name')]

${CONSOLE_LOG_LINK}            //li//span[text()='Console Output']/ancestor::a
${BUILDPAGE_CONSOLE_LOG_LINK}        //span[@class='task-link-text' and text()='Console Output']/ancestor::a

${CONSOLEPAGE_SPINNER}        //div[@id='spinner']/div[@class='lds-ellipsis']
${CONSOLEPAGE_CONSOLE_OUTPUT_TEXT}        //pre[@class='console-output']
${CONSOLEPAGE_FINISH_TEXT}        Finished: SUCCESS

${HELPSTAGINGPAGE_SELECT}        //form[@name='parameters']//select

*** Keywords ***
Login To Jenkins
    [Arguments]    ${username}    ${password}
    Open Browser To Login Page
    Login With Admin Credentials     ${username}    ${password}
    


Open Browser To Login Page
    # ${driver_path}=    webDriverManager.get_driver_path_with_browser     ${BROWSER}    
    Open Browser     ${BASE_URL}/login       ${BROWSER}     #executable_path=${driver_path}    
    Maximize Browser Window      

Login With Admin Credentials        
    [Arguments]    ${username}    ${password}
    Input Text    ${LOGINPAGE_USERNAME_TEXT}     ${username}
    Input Text    ${LOGINPAGE_PASSWORD_TEXT}     ${password}
    Click Button    ${LOGINPAGE_SUBMIT_BTN} 
    Title Should Be    Dashboard [Jenkins]

GoTo Specific Branch
    [Arguments]    ${branchVersion}    
    Go To         ${BASE_URL}/job/paris-web/job/${branchVersion}/
    Title Should Be    ${branchVersion} [Paris Web] [Jenkins]
Get Latest Build Number
    Wait Until Element Is Visible    ${BRANCHPAGE_LATEST_BUILD_NO}     timeout=60 seconds
    ${latestBuildNo}=     Get Element Attribute    ${BRANCHPAGE_LATEST_BUILD_NO}    innerText
    ${buildNo}=     Remove String    ${latestBuildNo}    \#
    Log    ${buildNo}
    RETURN     ${buildNo} 

Build Images For Specific Branch
    [Arguments]    ${branchVersion} 
    Go To         ${BASE_URL}/job/paris-web/job/${branchVersion}/build?delay=0sec
    ${title}=     Get Element Attribute    //h1    innerText
    Should Be Equal    ${title}    Branch ${branchVersion}
    Click Element    ${BRANCHPAGE_DRYRUN_LABEL}
    Checkbox Should Not Be Selected    ${BRANCHPAGE_DRYRUN_CHBOX}
    Click Button    ${BRANCHPAGE_BUILD_BTN}
    Sleep    5s

Waiting For Build Success
    Wait Until Element Is Visible    ${BRANCHPAGE_LATEST_BUILD_NO}     timeout=90 seconds
    Click Element     ${BRANCHPAGE_LATEST_BUILD_NO}    
    Sleep    1s
    Click Element     ${CONSOLE_LOG_LINK}
    Wait Until Element Is Not Visible        ${CONSOLEPAGE_SPINNER}    timeout=1000 seconds
    ${consoleLog}=     Get Element Attribute    ${CONSOLEPAGE_CONSOLE_OUTPUT_TEXT}    innerText
    Should Contain    ${consoleLog}    ${CONSOLEPAGE_FINISH_TEXT}

Deploy Specific Help Server
    [Arguments]    ${option}
    Go To    ${BASE_URL}${HELP_STAGING_URL}
    Select From List By Value    ${HELPSTAGINGPAGE_SELECT}    ${option}
    Click Button    ${BRANCHPAGE_BUILD_BTN}
    Sleep    3s