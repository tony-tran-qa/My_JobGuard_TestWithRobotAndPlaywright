*** Settings ***
Documentation     Smoke tests: the app loads and basic navigation works.
Resource          ../resources/common.resource
Suite Setup       Start Browser
Suite Teardown    Stop Browser
Test Setup        Open JobGuard
Test Teardown     Close JobGuard

*** Test Cases ***
App Loads With Six Tabs
    Get Element Count    button.tab    ==    ${6}
    Get Text    body    contains    JOBGUARD

Header Has No LinkedIn Branding
    [Documentation]    The header is upper-cased by CSS, so compare ignoring case.
    ${text}=    Get Text    body
    Should Not Contain    ${text}    linkedin    ignore_case=${True}
    Should Contain    ${text}    company intelligence & vetting    ignore_case=${True}

Vet Button Is Disabled Without A Company
    Get Property    button:has-text("Run Vetting Check")    disabled    ==    ${True}

Vet Button Enables When A Company Is Typed
    Fill Text    input[placeholder^="Company name"]    Some Company
    Get Property    button:has-text("Run Vetting Check")    disabled    ==    ${False}

Every Tab Can Be Opened
    FOR    ${tab}    IN    Records    Favorites    Agencies    Blacklist    Settings
        Go To Tab    ${tab}
        Get Element States    button.tab:has-text("${tab}")    contains    visible
    END

Blacklisted Company Is Blocked Without Calling The API
    Fill Text    input[placeholder^="Company name"]    TechHire Global
    Click    button:has-text("Run Vetting Check")
    Get Text    body    contains    BLACKLISTED COMPANY
