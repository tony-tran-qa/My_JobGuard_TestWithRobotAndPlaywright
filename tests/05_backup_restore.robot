*** Settings ***
Documentation     Settings tab: full backup export and restore. The folder picker (autosave) is a native
...               browser dialog and is not automated here.
Resource          ../resources/common.resource
Suite Setup       Start Browser
Suite Teardown    Stop Browser
Test Setup        Open JobGuard
Test Teardown     Close JobGuard

*** Test Cases ***
Export All Contains Every Data Set
    Seed Storage    jg_records    records_seed.json
    Seed Storage    jg_favs    favorites_seed.json
    Seed Storage    jg_orgs    agencies_seed.json
    Go To Tab    Settings
    ${data}=    Download From    export-all    jobguard-all-records.json
    Should Be Equal    ${data}[app]    jobguard
    Length Should Be    ${data}[records]    3
    Length Should Be    ${data}[favorites]    1
    Length Should Be    ${data}[agencies]    1
    Length Should Be    ${data}[blacklist]    5

Export All Never Includes The API Key
    Go To Tab    Settings
    Fill Text    input[type="password"]    sk-ant-api03-not-a-real-key
    Click    button:has-text("Save Key")
    ${data}=    Download From    export-all    jobguard-all-records.json
    ${text}=    Evaluate    json.dumps($data)    modules=json
    Should Not Contain    ${text}    sk-ant-api03-not-a-real-key

Restore Merges A Backup Into Empty App
    Go To Tab    Settings
    Import File Into    restore-input    backup_sample.json
    Get Text    body    contains    Restored:
    Stored Length Should Be    jg_blacklist    6
    Stored Length Should Be    jg_records    1
    Stored Length Should Be    jg_orgs    1

Restore Twice Does Not Duplicate
    Go To Tab    Settings
    Import File Into    restore-input    backup_sample.json
    Stored Length Should Be    jg_records    1
    Import File Into    restore-input    backup_sample.json
    Stored Length Should Be    jg_records    1
    Stored Length Should Be    jg_blacklist    6

Restore Rejects A File That Is Not A Backup
    Go To Tab    Settings
    Import File Into    restore-input    not_a_backup.json
    Get Text    body    contains    Restore failed

Restore Rejects Invalid JSON
    Go To Tab    Settings
    Import File Into    restore-input    invalid.json
    Get Text    body    contains    Restore failed
