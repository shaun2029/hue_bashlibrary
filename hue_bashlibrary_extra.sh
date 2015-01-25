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

    for i in `seq 1 3`;
    do
        hue_get_brightness $2

        if [ "$result_hue_get_brightness" == "$LEVEL" ]; then
            break;
        fi
    done

    # Already set to correct level then return
    if [ "$result_hue_get_brightness" == "$LEVEL" ]; then
        return
    fi

    # Turn on light
    for i in `seq 1 3`;
    do
        hue_is_on $2

        if [ "$result_hue_is_on" == 0 ]; then
            hue_onoff "on" $2
        fi
    done

    for i in `seq 1 3`;
    do
        for j in `seq 1 30`;
        do
            hue_setstate_brightness $LEVEL $2
            hue_get_brightness $2

            if [ "$result_hue_get_brightness" == "$LEVEL" ]; then
                break;
            fi
        done
    done

    # Turn off light if needed
    if [ "$LEVEL" == "0" ]; then
        for i in `seq 1 3`;
        do
            hue_is_on $2

            if [ "$result_hue_is_on" == 1 ]; then
                hue_onoff "off" $2
            fi
        done
    fi
}


function change_brightness() {
    LEVEL=-1

    # Do everything upto 3 times - seems to be inconsistancies
    # Get the current light level
    for i in `seq 1 3`;
    do
        hue_get_brightness $2

        if [ "$result_hue_get_brightness" != '' ]; then
            if [ "$LEVEL" != "$result_hue_get_brightness" ]; then
                LEVEL=$[result_hue_get_brightness]
            else
                break
            fi
        fi
    done        

    if [ "$LEVEL" == "-1" ]; then
        exit 1
    fi
                 
    # Get the new brightness level        
    NEWLEVEL=$[LEVEL + $1]
    
    set_brightness $NEWLEVEL $2
}
