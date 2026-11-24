*** Settings ***
Documentation     Shared setup and helpers for the JobGuard web UI tests.
Library           Browser
Library           OperatingSystem
Library           Collections
Library           String

*** Variables ***
${BASE_URL}       http://localhost:5173/
${HEADLESS}       ${True}
${DATA_DIR}       ${CURDIR}${/}..${/}data
${DOWNLOAD_DIR}   ${CURDIR}${/}..${/}results${/}downloads

*** Keywords ***
Start Browser
    [Documentation]    Suite setup: one browser for the whole suite.
    New Browser    chromium    headless=${HEADLESS}
    Create Directory    ${DOWNLOAD_DIR}

Stop Browser
    Close Browser

Open JobGuard
    [Documentation]    Test setup: fresh context (empty localStorage) and the app loaded.
    New Context    acceptDownloads=${True}    viewport={'width': 1100, 'height': 900}
    New Page    ${BASE_URL}
    Wait For Elements State    button.tab >> nth=0    visible

Close JobGuard
    Close Context

Go To Tab
    [Arguments]    ${label}
    Click    button.tab:has-text("${label}")

Seed Storage
    [Documentation]    Write a JSON file from data/ into a localStorage key, then reload so the app reads it.
    [Arguments]    ${key}    ${file}
    ${text}=    Get File    ${DATA_DIR}${/}${file}
    Evaluate JavaScript    ${None}    (v) => localStorage.setItem('${key}', v)    arg=${text}
    Reload
    Wait For Elements State    button.tab >> nth=0    visible

Stored List
    [Documentation]    Return the parsed JSON stored under a localStorage key.
    [Arguments]    ${key}
    ${value}=    Evaluate JavaScript    ${None}    () => JSON.parse(localStorage.getItem('${key}') || 'null')
    RETURN    ${value}

Download From
    [Documentation]    Click an export button and return the downloaded file's parsed JSON.
    [Arguments]    ${testid}    ${filename}
    ${promise}=    Promise To Wait For Download    ${DOWNLOAD_DIR}${/}${filename}
    Click    [data-testid="${testid}"]
    ${dl}=    Wait For    ${promise}
    ${text}=    Get File    ${dl}[saveAs]
    ${data}=    Evaluate    json.loads($text)    modules=json
    RETURN    ${data}

Import File Into
    [Arguments]    ${testid}    ${file}
    Upload File By Selector    [data-testid="${testid}"]    ${DATA_DIR}${/}${file}

Check Stored Length
    [Arguments]    ${key}    ${expected}
    ${list}=    Stored List    ${key}
    Length Should Be    ${list}    ${expected}

Stored Length Should Be
    [Documentation]    localStorage is written by a React effect, so retry briefly.
    [Arguments]    ${key}    ${expected}
    Wait Until Keyword Succeeds    5x    300ms    Check Stored Length    ${key}    ${expected}

Add Blacklist Entry
    [Arguments]    ${name}    ${reason}=${EMPTY}
    Click    button:has-text("Add Manually")
    Fill Text    input[placeholder="Company name"]    ${name}
    Fill Text    input[placeholder^="Reason"]    ${reason}
    Click    button:has-text("Add to Blacklist")

Add Agency
    [Arguments]    ${name}    ${type}=Staffing / Recruiter    ${url}=${EMPTY}
    Click    button:has-text("+ Add")
    Fill Text    input[placeholder="Company name"]    ${name}
    Fill Text    input[placeholder^="Website"]    ${url}
    Select Options By    select >> nth=0    label    ${type}
    Click    button:has-text("Save")
