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

NOW=$(getDate "next wed")

function generateNoteTemplate() {

NOTE="/*"
NOTE+=repeat 30 "="
NOTE+="\n"
NOTE+=repeat 30 "-"
NOTE+="\n"
NOTE+=$date
NOTE+="\n"
NOTE+=repeat 30 "-"
NOTE+="\n"
NOTE+=repeat 30 "="
NOTE+="\n"
NOTE+="*/"

}



