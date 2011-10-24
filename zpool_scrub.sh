#!/bin/bash
#
# this script will go through all pools and scrub them one at a time
#

ZPOOL=/usr/sbin/zpool
TMPFILE=/tmp/scrub.sh.$$.$RANDOM

scrub_in_progress() {
        if $ZPOOL status $1 | grep "scrub in progress" >/dev/null; then
                return 0
        else
                return 1
        fi
}

for pool in `$ZPOOL list -H -o name`; do
        $ZPOOL scrub $pool

        while scrub_in_progress $pool; do
                sleep 60
        done

        if ! $ZPOOL status $pool | grep "with 0 errors" >/dev/null; then
                $ZPOOL status $pool >>$TMPFILE
        fi
done

if [ -s $TMPFILE ]; then
        cat $TMPFILE
fi

rm -f $TMPFILE

