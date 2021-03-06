#!/bin/bash
#
# THIS IS SAMPLE.
#
# The MIT License (MIT)
# Copyright (c) 2016 tkumata
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
set -eu

THRESHOLD="45" # Your threshold of Wi-Fi RSSI.
COUNT="0"
COUNT_THRESHOLD="1"
SLEEP_TIMER="0.3"

function led_fire_on() {
    if [ "$(pgrep -f 'led_fire')" = "" ]; then
        /home/pi/bin/led_fire/led_fire.py &
    fi
}

function led_fire_off() {
    if [ "$(pgrep -f 'led_fire')" != "" ]; then
        pkill -f 'led_fire'
    fi
}

while :
do
    #link_quality="$(cat /proc/net/wireless | tail -1 | awk '{print $3}' | sed -e 's/\.//')"
    signal_level="$(cat /proc/net/wireless | tail -1 | awk '{print $4}' | sed -e 's/\-//' -e 's/\.//')"

    if [ "$THRESHOLD" -le "$signal_level" ]; then
        COUNT="$(($COUNT + 1))"
        #echo -e "$link_quality/70\t-$signal_level dBm"
        echo -n "x"
        if [ "$COUNT" -ge "$COUNT_THRESHOLD" ]; then
            led_fire_on
        fi
    else
        COUNT="0"
        echo -n "."
        led_fire_off
    fi

    if [ "$COUNT" -gt "100" ]; then
        COUNT="0"
        echo -n "."
    fi

    sleep $SLEEP_TIMER
done
