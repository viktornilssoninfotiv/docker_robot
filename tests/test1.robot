*** Settings ***
Documentation       Robot Framework sample test case
Library     SeleniumLibrary
Library     WaitForApp.py

*** Variables ***
${user_email}          hamid@gamil.se
${password}          123
${url_sample}               https://automationplayground.com/crm/
${URL}               http://localhost:5199

${New Customer}      id:new-customer
${email_field}           //*[@id="EmailAddress"]
${first_name_field}      //input[@id='FirstName']
${last_name_field}       //input[@id='LastName']
${city_field}            //input[@id='City']

# Default browser
${BROWSER}  headlesschrome
# Chrome browser options.
# Uses the no-sandbox option as a workaround for Chrome crashing when run as root in docker
# container on Jenkins.
# Sets the window size to ensure all elements are possible to interact with
# --disable-gpu to fix: Chrome crashing or "ERROR:command_buffer_proxy_impl.cc(128)] ContextResult::kTransientFailure:
# Failed to send GpuControl.CreateCommandBuffer."
${BROWSER_OPTIONS}  add_argument("--no-sandbox"); add_argument("--disable-gpu"); add_argument("window-size=1920,1080");

*** Test Cases ***
Sample test case with Chrome
    Open Browser        browser=${BROWSER}      options=${BROWSER_OPTIONS}
    Go To   ${url_sample}
    Wait Until Page Contains    Welcome


*** Keywords ***

Setup
    Open Browser        browser=${BROWSER}      options=${BROWSER_OPTIONS}
    Wait For Application    ${URL}    300    5
    Go To   ${url_sample}
    Wait Until Element Is Visible    //a[@class='navbar-brand col-sm-3 col-md-2 mr-0']


The User is on sign in page
    [Documentation]     Navigate to sign in page
    [Tags]      login
    Click Link    //a[@id='SignIn']

Is logged in
    [Documentation]                 Enter user information
    [Tags]                          login
    Input Text                      //*[@id="email-id"]   ${user_email}
    Input Password                  //*[@id="password"]   ${password}
    Click Button                    //button[@id='submit-id']
    Wait Until Element Is Visible   //*[@id="new-customer"]

A new customer is created
    [Tags]      customer
    Click Link      ${New Customer}
    Input Text      ${email_field}           ${user_email}
    Input Text      ${first_name_field}      Hamid
    Input Text      ${last_name_field}       Hosseini
    Input Text      ${city_field}            London
    Select From List By Index    //select[@id='StateOrRegion']      1
    Click Element       name:gender
    Click Element    name:promos-name
    Click Button        //*[@id="loginform"]/div/div/div/div/form/button

The customer has been successfully created
    Wait Until Element Is Visible    //div[@id='Success']
    Element Text Should Be    //h2[normalize-space()='Our Happy Customers']    Our Happy Customers



