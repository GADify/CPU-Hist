#!/bin/bash
#
# Gary A. Donahue 2014
#
# Written by GAD to provide historical info for CPU histogram
# This script is also probably lame, but it does the job

# It writes two files in order to make one an endlessly cycling
# repository of the last minute's %CPU idle (summ all CPUs)
# It reads from the rolling second file, then every minute determines
#    the average and peak for the past minute. It records this 
#    information thusly:

# This scrip uses two files: 
#   CPU-Hist-Min.txt         - Timestamp, ave%, peak% for last min
#   CPU-Hist-Min-Rolling.txt - Rolling tail of other file

# The Rolling file is the one to use when plotting


# Limitations: 
#              This script must be started at boot to be useful. 
#              
#              This script should be started as an agent if it is to be 
#              a critical tool.

PROGDIR="/opt/CPU-Hist/bin"
DATADIR="/opt/CPU-Hist/data"

# Set the mode to 666 so that any user may read the files written
umask 0111

# Create a lockfile to prevent multiple instances of script
LOCKFILE="$DATADIR/CPU-Min.lock"
PIDFILE="$DATADIR/CPU-Min.pid"
lockfile -r 0 $LOCKFILE || exit 1
echo $$ > $PIDFILE

# If script is killed, delete the lockfile
trap 'rm -f $LOCKFILE; rm -f $PIDFILE' EXIT

# Define the files to be used

SECFILE="$DATADIR/CPU-Hist-Sec-Rolling.txt"
MINFILE="$DATADIR/CPU-Hist-Min.txt"
MINROLLING="$DATADIR/CPU-Hist-Min-Rolling.txt"

COUNTER=0

# Sleep just over a minute before running the first time. This 
# lets the seconds file fill up in order to make a good first entry
# in the minutes file. 

#sleep 65

# Endless Loop
while true; do
   # take the last x lines of MIN File and put them into Rolling file.
   tail -n 180 $MINFILE > $MINROLLING

   # Increment the counter
   ((COUNTER++))

   # Seconds since Unix Epoch
   DATE=$(date +%s)

   # Determine ave and peak by using commonly available unix tools
   # on the MIN file
   AVE=$(tail -n 60 $SECFILE | awk '{s+=$2}END{printf "%.1f", s/60}')
   PEAK=$(tail -n 60 $SECFILE | awk '{print $2}' | sort -g | tail -1)

   # On first iteration of script, there is no peak, and this breaks the
   # plots. This forces a peak. This should only match on first iteration.

   if [[ -z $PEAK ]]; then
      PEAK=$AVE
   fi

   # Format of file is 'timestamp average peak'
   echo $DATE $AVE $PEAK >> $MINFILE

   # If first file gets too big, replace it with the rolling file
   # This is far easier than any other operation I came up with
   if (($COUNTER > 200)); then
      cp $MINROLLING $MINFILE
      let COUNTER=0
   fi

   # Sleep for one minute
   sleep 60
done
