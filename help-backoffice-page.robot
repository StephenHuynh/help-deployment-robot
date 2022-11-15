*** Settings ***
Documentation     Simple example using SeleniumLibrary.
Library         SeleniumLibrary
Library    String


*** Variables ***
########################## LOCATORS #######################################
${HELP_USERNAME_TEXT}        id:username
${HELP_PASSWORD_TEXT}        id:passwd
${HELP_SUBMIT_BTN}         id:btn-login

${HELP_APP_LAUNCHER}         //button[@title='App Launcher']
${HELP_APP_SELECTION_MENU}         //div[@class='drawer-menu-content']
${HELP_ADMINISTRATION_LINK}         //div[@class='drawer-menu-content']//li/a//span[text()='Administration']

${HELP_SYSTEM_INFO_LINK}         //a[@title='System Info']

${BUILD_VERSION_TEXT}        //section[@class='panel panel-default']//span[text()='Release Info:']/ancestor::header//parent::section//td[text()='Version: ']/following-sibling::td
${BUILD_NO_TEXT}        //section[@class='panel panel-default']//span[text()='Release Info:']/ancestor::header//parent::section//td[text()='Build Id:']/following-sibling::td


*** Keywords ***
Log Into BackOffice        
    [Arguments]    ${URL}     ${username}    ${password}
    Go To         ${URL}
    Input Text    ${HELP_USERNAME_TEXT}     ${username}
    Input Text    ${HELP_PASSWORD_TEXT}     ${password}
    Click Button    ${HELP_SUBMIT_BTN} 
    Sleep    5s

Go To System Infor Page
    Wait Until Element Is Visible    ${HELP_APP_LAUNCHER}    
    Click Element         ${HELP_APP_LAUNCHER}
    Wait Until Element Is Visible    ${HELP_APP_SELECTION_MENU}    
    Click Element         ${HELP_ADMINISTRATION_LINK}
    Wait Until Element Is Visible    ${HELP_SYSTEM_INFO_LINK}     timeout=60 seconds
    Click Element         ${HELP_SYSTEM_INFO_LINK}

Verify Build Number From System Info Page
    [Arguments]    ${EXPECTED_BUILD_NO}     
    Wait Until Element Is Visible    ${BUILD_NO_TEXT}     timeout=60 seconds
    ${ACTUAL_BULD_NO}=     Get Element Attribute    ${BUILD_NO_TEXT}    innerText
    Should Be Equal As Strings     ${EXPECTED_BUILD_NO}     ${ACTUAL_BULD_NO}