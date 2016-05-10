#!/bin/bash
#
# Gary A. Donahue 2014
#
# Written by GAD to provide historical info for CPU histogram
# This script is also probably lame, but it does the job

# It writes two files in order to make one an endlessly cycling
# repository of the last hour's %CPU idle (summ all CPUs)
# It reads from the rolling minute file, then every hour determines
#    the average and peak for the past minute. It records this 
#    information thusly:

# This scrip uses two files: 
#   CPU-Hist-Hrs.txt         - Timestamp, ave%, peak% for last min
#   CPU-Hist-Hrs-Rolling.txt - Rolling tail of other file

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
LOCKFILE="$DATADIR/CPU-Hrs.lock"
PIDFILE="$DATADIR/CPU-Hrs.pid"
lockfile -r 0 $LOCKFILE || exit 1
echo $$ > $PIDFILE

# If script is killed, delete the lockfile
trap 'rm -f $LOCKFILE; rm -f $PIDFILE' EXIT

# Define the files to be used

MINROLLING="$DATADIR/CPU-Hist-Min-Rolling.txt"
HRSFILE="$DATADIR/CPU-Hist-Hrs.txt"
HRSROLLING="$DATADIR/CPU-Hist-Hrs-Rolling.txt"

COUNTER=0

# This forces this script to sleep for over a minute before it starts.
# If we don't do this, then there is no data in the minutes file, and 
# the first entry of the hrs file has no peaks, which breaks the plots. 

#sleep 70

# Endless Loop
while true; do
   # take the last x lines of Hrs File and put them into Rolling file.
   tail -n 180 $HRSFILE > $HRSROLLING

   # Increment the counter
   ((COUNTER++))

   # Seconds since Unix Epoch
   DATE=$(date +%s)

   # Determine ave and peak by using commonly available unix tools
   # on the MIN file (Assumes no breaks in data)
   AVE=$(tail -n 60 $MINROLLING | awk '{s+=$2}END{printf "%.1f", s/60}')
   PEAK=$(tail -n 60 $MINROLLING | awk '{print $2}' | sort -g | tail -1)

   # On first iteration of script, there is no peak, and this breaks the
   # plots. This forces a peak. This should only match on first iteration.

   if [[ -z $PEAK ]]; then
      PEAK=$AVE
   fi

   # Format of file is 'timestamp average peak'
   echo $DATE $AVE $PEAK >> $HRSFILE

   # If first file gets too big, replace it with the rolling file
   # This is far easier than any other operation I came up with
   if (($COUNTER > 200)); then
      cp $HRSROLLING $HRSFILE
      let COUNTER=0
   fi

   # Sleep for one hour
   sleep 3600
done
