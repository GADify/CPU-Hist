#!/bin/bash
#
# Gary A. Donahue 2014
#
# impulses, lines
Now=$(date +%s)
# Get Length, Width, ($1, $2) else assign them
WIDTH=${1-74}
LENGTH=${2-20}
echo '                                    \
   set term dumb ' $WIDTH $LENGTH ';      \
   set title "CPU Utilization - 3 Days";  \
   set xlabel "Hours";                    \
   set yrange [0:100];                    \
   set xrange [0:72];                     \
   set xtics axis nomirror;               \
   set ytics axis nomirror 0,25,100 ; \
   set key off;                           \
   plot "/opt/CPU-Hist/data/CPU-Hist-Hrs.txt" \
             using (('$Now'-$1)/3600):3 title "Peak:" with dots, \
        "/opt/CPU-Hist/data/CPU-Hist-Hrs.txt" \
             using (('$Now'-$1)/3600):2:x2tic(2) title "Average:" with impulses '\
 | gnuplot
