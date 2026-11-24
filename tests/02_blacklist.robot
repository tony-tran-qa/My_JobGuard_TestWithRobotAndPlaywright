*** Settings ***
Documentation     Blacklist tab: defaults, add, remove, persistence, export and import.
Resource          ../resources/common.resource
Suite Setup       Start Browser
Suite Teardown    Stop Browser
Test Setup        Open JobGuard
Test Teardown     Close JobGuard

*** Test Cases ***
Default Blacklist Has Five Entries
    Go To Tab    Blacklist
    Get Element Count    .bl-row    ==    ${5}

Warning Shown When No Saved Blacklist Exists
    Go To Tab    Blacklist
    Get Text    body    contains    No saved blacklist was found
    Click    button:has-text("Dismiss")
    Get Text    body    not contains    No saved blacklist was found

Add Entry Manually
    Go To Tab    Blacklist
    Add Blacklist Entry    Fake Recruiters Ltd    Asked for gift cards
    Get Element Count    .bl-row    ==    ${6}
    Get Text    body    contains    Fake Recruiters Ltd
    Stored Length Should Be    jg_blacklist    6

Added Entry Survives Reload
    Go To Tab    Blacklist
    Add Blacklist Entry    Persistent Scam Co
    Stored Length Should Be    jg_blacklist    6
    Reload
    Go To Tab    Blacklist
    Get Element Count    .bl-row    ==    ${6}
    Get Text    body    contains    Persistent Scam Co

Remove Entry
    Go To Tab    Blacklist
    Click    .bl-row:has-text("TechHire Global") >> .rm-btn
    Get Element Count    .bl-row    ==    ${4}
    Get Text    body    not contains    TechHire Global

Export Downloads Blacklist Only
    Go To Tab    Blacklist
    ${data}=    Download From    export-blacklist    jobguard-blacklist.json
    Length Should Be    ${data}    5
    Should Be Equal    ${data}[0][name]    TechHire Global
    Should Not Be True    isinstance($data, dict)

Import Merges And Skips Duplicates
    Go To Tab    Blacklist
    Import File Into    import-blacklist    blacklist_import.json
    Get Text    body    contains    Imported 2
    Get Element Count    .bl-row    ==    ${6}
    Get Text    body    contains    ScamCorp Imported

Import Rejects Invalid File
    Go To Tab    Blacklist
    Import File Into    import-blacklist    invalid.json
    Get Text    body    contains    Import failed
    Get Element Count    .bl-row    ==    ${5}
