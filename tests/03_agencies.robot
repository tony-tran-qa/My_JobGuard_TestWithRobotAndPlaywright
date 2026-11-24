*** Settings ***
Documentation     Agencies tab: add, change type, remove, export, import, scan Records.
Resource          ../resources/common.resource
Suite Setup       Start Browser
Suite Teardown    Stop Browser
Test Setup        Open JobGuard
Test Teardown     Close JobGuard

*** Test Cases ***
Starts Empty
    Go To Tab    Agencies
    Get Text    body    contains    No firms listed yet

Add A Staffing Firm
    Go To Tab    Agencies
    Add Agency    Acme Staffing
    Get Element Count    .bl-row    ==    ${1}
    Get Text    body    contains    Acme Staffing
    Stored Length Should Be    jg_orgs    1
    ${orgs}=    Stored List    jg_orgs
    Should Be Equal    ${orgs}[0][type]    Staffing / Recruiter

Add An IT Consulting Firm With Website
    Go To Tab    Agencies
    Add Agency    Initech    IT Consulting    https://initech.example
    Get Text    .bl-row    contains    initech.example
    ${orgs}=    Stored List    jg_orgs
    Should Be Equal    ${orgs}[0][type]    IT Consulting

Change Type Of A Listed Firm
    Go To Tab    Agencies
    Add Agency    Acme Staffing
    Select Options By    .bl-row select    label    IT Consulting
    Wait Until Keyword Succeeds    5x    300ms    Type Of First Org Should Be    IT Consulting

Remove A Firm
    Go To Tab    Agencies
    Add Agency    Acme Staffing
    Click    .bl-row >> .rm-btn
    Get Text    body    contains    No firms listed yet

Duplicate Name Updates Instead Of Adding
    Go To Tab    Agencies
    Add Agency    Acme Staffing
    Add Agency    acme staffing    IT Consulting
    Get Element Count    .bl-row    ==    ${1}

Export Downloads Agencies Only
    Go To Tab    Agencies
    Add Agency    Acme Staffing
    ${data}=    Download From    export-agencies    jobguard-agencies.json
    Length Should Be    ${data}    1
    Should Be Equal    ${data}[0][name]    Acme Staffing

Import Merges Agencies
    Go To Tab    Agencies
    Import File Into    import-agencies    agencies_import.json
    Get Element Count    .bl-row    ==    ${2}
    Get Text    body    contains    Robert Half

Scan Records Adds Staffing Firms From The AI Company Type
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Agencies
    Click    button:has-text("Scan Records")
    Get Text    body    contains    Added 1
    Get Element Count    .bl-row    ==    ${1}
    Get Text    .bl-row    contains    Allegis Group

*** Keywords ***
Type Of First Org Should Be
    [Arguments]    ${expected}
    ${orgs}=    Stored List    jg_orgs
    Should Be Equal    ${orgs}[0][type]    ${expected}
