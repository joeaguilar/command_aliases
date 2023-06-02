#!/bin/bash

function downloadFromYoutube() {
    if [ $# -eq 0 ]
    then
        echo "No arguments supplied - start 00:00:15.00 end 00:00:25.00"
        done;
    fi
    youtube-dl -x --audio-format mp3 $1
    if [ $# -eq 3 ]
    then

    ffmpeg -ss $2 -i "OUTPUT-OF-FIRST URL" -to $3 -c copy out.mp4
    fi
    mv ~/stuff/* /mnt/c/Users/BlueSourBoy/FromTheOtherSide/ 
}
