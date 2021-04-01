*** Settings ***
Documentation       Test for Trello API
Library             RequestsLibrary
Library             Collections
Suite Setup         Create Session For Endpoint
Resource            Resources.robot

*** Test Cases ***
Check If CREATE A List Creates New List
    [Tags]                                          LISTS
    ${board_name}                                   Set Variable              New Board
    ${resp}                                         Create A Board            ${board_name}
    Request Should Be Successful                    ${resp}
    ${new_board_id}                                 Take ID from New Board    ${resp}
    Set Suite Variable      ${BOARD_ID}             ${new_board_id}
    ${list_name}            Set Variable            New List
    ${resp}                 Create A List           ${list_name}
    Request Should Be Successful                    ${resp}
    ${new_list_id}          Take ID from New List   ${resp}
    Set Suite Variable      ${LIST_ID}              ${new_list_id}
    Validate List Name In The Response              ${resp}                   ${list_name}

Check If GET A LIST With Correct Id Returns Expected List
    [Tags]                                 LISTS
    ${resp}                                Get A List         ${LIST_ID}
    Request Should Be Successful           ${resp}
    Validate List Id In The Response       ${resp}            ${LIST_ID}

Check If GET A LIST With Inorrect Id Returns "Invalid id" In The Response
    [Tags]                                LISTS
    ${wrong_list_id}                      Set Variable                  26    [NUMBERS][LETTERS]
    ${resp}                               Get A List With Wrong Id      ${wrong_list_id}
    Validate Bad Status Code        ${resp.status_code}
    Validate "Invalid id" Response  ${resp.content}

Check if GET THE BOARD A LIST IS ON Returns Expected Board
    [Tags]                                 LISTS
    ${resp}                                Get A Board A List Is On         ${LIST_ID}
    Request Should Be Successful           ${resp}
    Validate Board Id In The Response      ${resp}                          ${BOARD_ID}

Check if UPDATE A LIST updates a list
    [Tags]                                 LISTS
    ${resp}       Update A List       ${LIST_ID}
    Request Should Be Successful      ${resp}




*** Keywords ***
Create Session For Endpoint
    Create Session      trello                 ${URL}

Create A Board
    [Arguments]         ${board_name}
    ${params}           Create Dictionary      name=${board_name}    token=${YOUR_TOKEN}    key=${YOUR_KEY}
    ${resp}             Post Request           trello    ${ENDPOINT}    params=${params}
    ${resp_json}        To Json                ${resp.text}          pretty_print=${True}
    Log                 ${resp_json}
    [Return]            ${resp}

Create A List
    [Arguments]         ${list_name}
    ${params}           Create Dictionary      idBoard=${BOARD_ID}    name=${list_name}    token=${YOUR_TOKEN}    key=${YOUR_KEY}
    ${resp}             Post Request           trello    ${ENDPOINT2}    params=${params}
    ${resp_json}        To Json                ${resp.text}         pretty_print=${True}
    Log                 ${resp_json}
    [Return]            ${resp}

Get A Board
    [Arguments]         ${BOARD_ID}
    ${params}           Create Dictionary      token=${YOUR_TOKEN}    key=${YOUR_KEY}
    ${resp}             Get Request            trello    ${ENDPOINT1}${BOARD_ID}    params=${params}
    ${resp_json}        To Json                ${resp.text}           pretty_print=${True}
    Log                 ${resp_json}
    [Return]            ${resp}

Get A List
    [Arguments]         ${LIST_ID}
    ${params}           Create Dictionary      token=${YOUR_TOKEN}    key=${YOUR_KEY}
    ${resp}             Get Request            trello    ${ENDPOINT3}${LIST_ID}    params=${params}
    ${resp_json}        To Json                ${resp.text}           pretty_print=${True}
    Log                 ${resp_json}
    [Return]            ${resp}

Get A Board a List is on
    [Arguments]         ${LIST_ID}
    ${params}           Create Dictionary      token=${YOUR_TOKEN}    key=${YOUR_KEY}
    ${resp}             Get Request            trello    ${ENDPOINT3}${LIST_ID}/board    params=${params}
    ${resp_json}        To Json                ${resp.text}           pretty_print=${True}
    Log                 ${resp_json}
    [Return]            ${resp}

Get A List With Wrong Id
    [Arguments]         ${wrong_list_id}
    ${params}           Create Dictionary      token=${YOUR_TOKEN}    key=${YOUR_KEY}
    ${resp}             Get Request            trello    ${ENDPOINT3}${wrong_list_id}    params=${params}
    Log                 ${resp}
    [Return]            ${resp}

Update A List
    [Arguments]         ${LIST_ID}
    ${params}           Create Dictionary      token=${YOUR_TOKEN}    key=${YOUR_KEY}
    ${resp}             Put Request            trello    ${ENDPOINT3}${LIST_ID}    params=${params}
    ${resp_json}        To Json                ${resp.text}           pretty_print=${True}
    Log                 ${resp_json}
    [Return]            ${resp}

Validate List Name In The Response
    [Arguments]          ${resp}               ${list_name}
    ${resp_dict}         Set Variable          ${resp.json()}
    Should Be Equal As Strings                 ${resp_dict}[name]   ${list_name}

Validate List Id In The Response
    [Arguments]          ${resp}               ${LIST_ID}
    ${resp_dict}         Set Variable          ${resp.json()}
    Should Be Equal As Strings                 ${resp_dict}[id]   ${LIST_ID}

Validate Board Id In The Response
    [Arguments]          ${resp}               ${BOARD_ID}
    ${resp_dict}         Set Variable          ${resp.json()}
    Should Be Equal As Strings                 ${resp_dict}[id]   ${BOARD_ID}

Take ID from New Board
    [Arguments]          ${resp}
    ${resp_dict}         Set Variable          ${resp.json()}
    ${board_id}          Set Variable          ${resp_dict}[id]
    Log                  ${board_id}
    [Return]             ${board_id}

Take ID from New List
    [Arguments]          ${resp}
    ${resp_dict}         Set Variable          ${resp.json()}
    ${list_id}          Set Variable          ${resp_dict}[id]
    Log                  ${list_id}
    [Return]             ${list_id}

Validate Bad Status Code
    [Arguments]         ${resp.status_code}
    Log                 ${resp.status_code}
    ${status}           Convert To String       ${resp.status_code}
    Should Be Equal     ${status}               400

Validate "Invalid id" Response
    [Arguments]         ${resp.content}
    ${response}         Convert To String       ${resp.content}
    Should Be Equal     ${response}             invalid id

