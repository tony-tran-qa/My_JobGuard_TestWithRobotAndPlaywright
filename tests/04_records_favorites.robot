*** Settings ***
Documentation     Records and Favorites tabs, driven from seeded localStorage (no API key or network needed).
Resource          ../resources/common.resource
Suite Setup       Start Browser
Suite Teardown    Stop Browser
Test Setup        Open JobGuard
Test Teardown     Close JobGuard

*** Test Cases ***
Records List Shows Seeded Records
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Records
    Get Element Count    .rec-card    ==    ${3}
    Get Text    body    contains    Acme Software

Records Search Filters By Company
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Records
    Fill Text    input[placeholder^="Search company"]    acme
    Get Element Count    .rec-card    ==    ${1}

Unlisted Staffing Company Is Tagged Auto
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Records
    Get Text    .rec-card:has-text("Allegis Group")    contains    Staffing / Recruiter (auto)

Direct Employer Is Tagged Direct
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Records
    Get Text    .rec-card:has-text("Acme Software")    contains    Direct

Listed Firm Shows Its Confirmed Type
    Seed Storage    jg_records    records_seed.json
    Seed Storage    jg_orgs    agencies_seed.json
    Go To Tab    Records
    Get Text    .rec-card:has-text("Globex Consulting")    contains    IT Consulting
    Get Text    .rec-card:has-text("Globex Consulting")    not contains    (auto)

Firm Type Filter Agencies Only
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Records
    Select Options By    select.sel >> nth=0    value    ORG_ANY
    Get Element Count    .rec-card    ==    ${1}
    Get Text    .rec-card    contains    Allegis Group

Firm Type Filter Direct Only
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Records
    Select Options By    select.sel >> nth=0    value    ORG_NONE
    Get Element Count    .rec-card    ==    ${2}

Export Downloads Records Only
    Seed Storage    jg_records    records_seed.json
    Go To Tab    Records
    ${data}=    Download From    export-records    jobguard-records.json
    Length Should Be    ${data}    3
    ${names}=    Evaluate    sorted(r['company'] for r in $data)
    Should Be Equal    ${names}[0]    Acme Software
    Should Be Equal    ${names}[1]    Allegis Group
    Should Be Equal    ${names}[2]    Globex Consulting

Import Records Twice Does Not Duplicate
    Go To Tab    Records
    Import File Into    import-records    records_seed.json
    Get Element Count    .rec-card    ==    ${3}
    Import File Into    import-records    records_seed.json
    Get Element Count    .rec-card    ==    ${3}

Favorites Show Seeded Entry
    Seed Storage    jg_favs    favorites_seed.json
    Go To Tab    Favorites
    Get Text    body    contains    Acme Software
    Get Text    body    contains    1 saved

Favorites Export And Import
    Seed Storage    jg_favs    favorites_seed.json
    Go To Tab    Favorites
    ${data}=    Download From    export-favorites    jobguard-favorites.json
    Length Should Be    ${data}    1
    Import File Into    import-favorites    favorites_seed.json
    Stored Length Should Be    jg_favs    1
