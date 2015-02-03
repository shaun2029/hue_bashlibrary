#!/bin/bash

# import my hue bash library
source hue_bashlibrary.sh

function set_brightness() {
    LEVEL=$1
    if [[ $LEVEL -gt 254 ]]; then
        LEVEL=254
    fi

    if [[ $1 -lt 0 ]]; then
        LEVEL=0
    fi

    hue_is_on $2

    # Turn on light if brightness > 0
    if [ "$result_hue_is_on" == 0 ]; then
        hue_onoff "on" $2
    fi

    # Ensure light level 'takes'
    for j in `seq 1 3`;
    do
        hue_setstate_brightness $LEVEL $2
        hue_get_brightness $2

        if [ "$result_hue_get_brightness" == "$LEVEL" ]; then
            break;
        fi
    done

    # Turn off light if brightness = 0
    if [ "$LEVEL" == "0" ]; then
        hue_is_on $2

        if [ "$result_hue_is_on" == 1 ]; then
            hue_onoff "off" $2
        fi
    fi
}


function change_brightness() {
    LEVEL=-1

    hue_get_brightness $2

    hue_is_on $1

    # if the light is off the brightness level = 0
    if [ "$STATE" == 1 ]; then
    	if [ "$result_hue_get_brightness" != '' ]; then
            LEVEL=$[result_hue_get_brightness]
    	else
            exit 1
    	fi
    else
        LEVEL=0
    fi

    # Calculate the new brightness level
    NEWLEVEL=$[LEVEL + $1]

    set_brightness $NEWLEVEL $2
}

function toggle_state() {
    STATE=-1

    hue_is_on $1

    # Toggle state
    if [ "$STATE" == 1 ]; then
        STATE=0
    else
        STATE=1
    fi

    if [ $STATE == 0 ]; then
        hue_onoff "off" $1
    else
        hue_onoff "on" $1
    fi

    hue_is_on $1
}
