#!/bin/bash
#
# Gary A. Donahue 2014
#
# Written by GAD to provide historical info for CPU histogram
# This script is probably lame, but it does the job

# Update Nov 2014: I've rewritten this to stop using vmstat and to
#        determine the CPU load properly using info found in /proc/stat
#        This has significanly improved the impact of this script on the box

# It writes two files in order to make one an endlessly cycling
# repository of the last second's %CPU utilization (summ all CPUs)
# %Util is the inverse of %idle as reported by the second line of vmstat

# This script uses two files: 
#   CPU-Hist-Sec.txt         - timestamp and CPU idle%
#   CPU-Hist-Sec-Rolling.txt - rolling tail of other file

# The Rolling file is the one to use when plotting

# Limitations: 
#              This script must be started at boot to be useful. 
#              This script should be started as an agent if it is to be 
#              a critical tool.

PROGDIR="/opt/CPU-Hist/bin"
DATADIR="/opt/CPU-Hist/data"

# Set the mode to 666 so that any user may read the files written
umask 0111

# Create a lockfile to prevent multiple instances of script
LOCKFILE="$DATADIR/CPU-Sec.lock"
PIDFILE="$DATADIR/CPU-Sec.pid"
lockfile -r 0 $LOCKFILE || exit 1
echo $$ > $PIDFILE

# If script is killed, delete the lockfile
trap 'rm -f $LOCKFILE; rm -f $PIDFILE' EXIT

# Define the files to be used
SECFILE="$DATADIR/CPU-Hist-Sec.txt"
SECROLLING="$DATADIR/CPU-Hist-Sec-Rolling.txt"


COUNTER=0
OLDTOTAL=0
OLTUTIL=0
OLDIDLE=0

# Endless loop
while true; do 

   # take the last x lines (if file exists) and put them into another file.
   tail -n 180 $SECFILE > $SECROLLING
   ((COUNTER++))
   # Seconds since Unix Epoch
   DATE=$(date +%s)

   # %Idle pulled from vmstat because that's what's availible in EOS
   #IDLE=$((100-$(vmstat 1 2 | tail -n 1 | awk '{ print $15 }')))

   # Get /proc/stat value for aggregated CPU (CPU without a number)

   # Values within /proc/stat for CPU: 

   #     User    Nice  System  Idle      Iowait IRQ SoftIRQ Steal  Guest Guest_nice
   # cpu 3343134 61955 3005348 658623498 175155 259 7115    45213  0     0
   
   read cpu USER NICE SYSTEM IDLE IOWAIT IRQ SOFTIRQ STEAL GUEST GUESTNICE < /proc/stat
   
   TOTAL=$((USER+NICE+SYSTEM+IDLE+IOWAIT+IRQ+SOFTIRQ+STEAL+GUEST+GUESTNICE))
   UTIL=$((TOTAL-IDLE))
  
   TOTALDIFF=$((OLDTOTAL-TOTAL)) 
   #IDLEDIFF=$((OLDIDLE-IDLE)) 
   UTILDIFF=$((OLDUTIL-UTIL)) 

   # A rare EOS rant - EOS does not include the bash command "bc", 
   # so I have to use awk. I are annoyed. 
   # Awk sometimes reports -0 on 0 values, but GnuPlot doesn't seem to care,
   # so I left it as is. BTW, Awk doesn't support abs(), either. 
   
   #PERCENTIDLE=$(awk -v I=$IDLEDIFF -v T=$TOTALDIFF 'BEGIN { printf "%3.2f", (100*(int(I)/int(T))) }')
   PERCENTUTIL=$(awk -v U=$UTILDIFF -v T=$TOTALDIFF 'BEGIN { printf "%3.2f", (100*(int(U)/int(T))) }')

   # Dump the info to the SEC file (Old IDLE was actually UTIL. D'oh!)
   #echo $DATE " " $IDLE >> $SECFILE
   echo $DATE " " $PERCENTUTIL >> $SECFILE

   OLDIDLE=$IDLE
   OLDUTIL=$UTIL
   OLDTOTAL=$TOTAL

   # If first file gets too big, replace it with the rolling file
   # This is far easier than any other operation I came up with
   if (($COUNTER > 200)); then 
      cp $SECROLLING $SECFILE
      let COUNTER=0
   fi

   # Sleep for one second
   sleep 1 
done
