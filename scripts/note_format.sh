#!/usr/bin/env bash

#Note format to use
NOTE_FORMAT="%m/%d/%Y %a"

# Repeat given char N times using shell function
function repeat () {
    TEXT=""
    local start=1
	local end=${1:-80}
	local str="${2}"
    local range=$(seq $start $end)
    for i in $range; do
        TEXT+="${str}";
    done;
    echo $TEXT;
}

function getDate() {
    local today=$(date)
    local setDate=${1:-$today}
    # printf -v date '%(%m/%d/%Y %a)T\n' -1 && echo $date
    # echo $(date --date="$setDate" '%(%m/%d/%Y %a)T\n' )
    echo $(date --date="$setDate" "+$NOTE_FORMAT" )
}

function generateNoteTemplate() {

    local date=$(getDate $1)
    local newLine="* "

    NOTE="/*"
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "=")
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "-")
    NOTE+="\n"$newLine
    NOTE+="  "$date
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "-")
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "=")
    NOTE+="\n"$newLine
    NOTE+="*/"

    echo -e "$NOTE"

}

# A more generic version
# This could be useful. Leaving here, it has nowhere else to live
function generateTemplate() {

    local textToWrap=$1
    local newLine="* "

    NOTE="/*"
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "=")
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "-")
    NOTE+="\n"$newLine
    NOTE+="  "${1:- }
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "-")
    NOTE+="\n"$newLine
    NOTE+=$(repeat 30 "=")
    # NOTE+="\n"$newLine
    NOTE+="\n*/\n\n\n "

echo -e "$NOTE"

}

# we should go with this next time
function generateHeadingBruteForce() {
    echo -e "/*"
    echo -e "* ============================="
    echo -e "* -----------------------------"
    echo -e "  $1"
    echo -e "* -----------------------------"
    echo -e "* ============================="
    echo -e "*/\n\n"
}

function generateNoteTemplateForAWeek() {
    local start_date=$1
    local noteText=""

    for i in {0..6};
    do
        date=$(getDate "${start_date}+${i}day");
        noteText+=$(generateTemplate "$date");
    done

    echo "$noteText"
}

function startDateAtMonday() {
    local start_date=${1:-now}
    local dayOfTheWeek=$(date --date="$start_date" +%u)
    local beginningOfTheWeekOffset=$[ $dayOfTheWeek - 1]
    echo $(date --date="$start_date -${beginningOfTheWeekOffset} days" "+$NOTE_FORMAT")
}

function run () {
    if [ -z "$2" ]; then
       generateNoteTemplateForAWeek $1
    else
       generateNoteTemplateForAWeek "$(startDateAtMonday $1)";
    fi
}


run $1 $2





