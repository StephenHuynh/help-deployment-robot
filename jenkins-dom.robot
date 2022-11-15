*** Settings ***
Documentation     Simple example using SeleniumLibrary.
Library         SeleniumLibrary
Library    String

Resource        jenkins-page.robot

*** Variables ***
${BASE_URL}      https://build.noriacloud.com/jenkins
${BROWSER}        Chrome

${HELP_STAGING_URL}             /job/Tools/job/ContinuousDelivery/job/help-staging/build


########################## LOCATORS #######################################
${LOGINPAGE_USERNAME_TEXT}        id:j_username
${LOGINPAGE_PASSWORD_TEXT}        //input[@name='j_password']
${LOGINPAGE_SUBMIT_BTN}         //button[@name='Submit']

${BRANCHPAGE_CHBOX}        //span[@class='jenkins-checkbox']
${BRANCHPAGE_DRYRUN_CHBOX}        //span[@class='jenkins-checkbox']/label[contains(text(),'DRY_RUN')]/preceding-sibling::input
${BRANCHPAGE_DRYRUN_LABEL}        //span[@class='jenkins-checkbox']/label[contains(text(),'DRY_RUN')]
${BRANCHPAGE_DRYRUN_LABEL_DOM}        document.querySelector("input[value='DRY_RUN']").nextElementSibling.querySelector('label')

${BRANCHPAGE_BUILD_BTN_DOM}         dom:document.querySelector("button[type='submit']")
${BRANCHPAGE_LATEST_BUILD_NO}         //div[@id='buildHistory']//div[@class='row pane-content']//tr[@page-entry-id][1]//a[contains(@class,'display-name')]
${BRANCHPAGE_LATEST_BUILD_NO_DOM}         dom:document.querySelector("a[update-parent-class='.build-row']")

${CONSOLE_LOG_LINK_TEXT}            	link:Console Output
${BUILDPAGE_CONSOLE_LOG_LINK}        //span[@class='task-link-text' and text()='Console Output']/ancestor::a

${CONSOLEPAGE_SPINNER}        //div[@id='spinner']/div[@class='lds-ellipsis']
${CONSOLEPAGE_CONSOLE_OUTPUT_TEXT}        //pre[@class='console-output']
${CONSOLEPAGE_FINISH_TEXT}        Finished: SUCCESS

${HELPSTAGINGPAGE_SELECT}        //form[@name='parameters']//select

*** Keywords ***
[Headless] Login To Jenkins
    [Arguments]    ${username}    ${password}
    Open Headless Browser To Login Page
    Login With Admin Credentials     ${username}    ${password}
    

Open Headless Browser To Login Page
    Open Browser     ${BASE_URL}/login     ${BROWSER}     options=add_argument("--no-sandbox"); add_argument("--headless"); add_argument("--disable-dev-shm-usage"); add_argument("--window-size=1920x1080")      

[Headless] Build Images For Specific Branch
    [Arguments]    ${branchVersion} 
    Go To         ${BASE_URL}/job/paris-web/job/${branchVersion}/build?delay=0sec
    Wait Until Element Is Visible    ${BRANCHPAGE_CHBOX}     timeout=60 seconds
    ${title}=     Get Element Attribute    //h1    innerText
    Should Be Equal    ${title}    Branch ${branchVersion}
    Click Button By Javascript     ${BRANCHPAGE_DRYRUN_LABEL_DOM}
    Checkbox Should Not Be Selected    ${BRANCHPAGE_DRYRUN_CHBOX}
    Click Button By Javascript    ${BRANCHPAGE_BUILD_BTN_DOM}
    Sleep    3s

[Headless] Waiting For Build Success
    Wait Until Element Is Visible    ${BRANCHPAGE_LATEST_BUILD_NO}     timeout=90 seconds
    Click Button By Javascript    ${BRANCHPAGE_LATEST_BUILD_NO_DOM}    
    Sleep    1s
    Click Link    ${CONSOLE_LOG_LINK_TEXT}
    Wait Until Element Is Not Visible        ${CONSOLEPAGE_SPINNER}    timeout=1000 seconds
    ${consoleLog}=     Get Element Attribute    ${CONSOLEPAGE_CONSOLE_OUTPUT_TEXT}    innerText
    Should Contain    ${consoleLog}    ${CONSOLEPAGE_FINISH_TEXT}

[Headless] Deploy Specific Help Server
    [Arguments]    ${option}
    Go To    ${BASE_URL}${HELP_STAGING_URL}
    Select From List By Value    ${HELPSTAGINGPAGE_SELECT}    ${option}
    Click Button By Javascript    ${BRANCHPAGE_BUILD_BTN_DOM}
    Sleep    3s

Click Button By Javascript
    [Arguments]    ${DOM}
    Execute Javascript    ${DOM}.click()    