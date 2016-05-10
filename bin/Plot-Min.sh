#!/bin/bash
#
# Gary A. Donahue 2014
#
# impulses, lines
Now=$(date +%s)
# Get Length, Width, ($1, $2) else assign them
WIDTH=${1-74}
LENGTH=${2-20}
echo '                                     \
   set term dumb ' $WIDTH $LENGTH ';       \
   set title "CPU Utilization - 3 Hours";  \
   set xlabel "Minutes";                   \
   set yrange [0:100];                     \
   set xrange [0:180];                     \
   set xtics axis nomirror;                \
   set ytics 0,25,100 nomirror;   \
   set key off;                            \
   plot "/opt/CPU-Hist/data/CPU-Hist-Min.txt" \
            using (('$Now'-$1)/60):3 title "Peak:" with dots, \
        "/opt/CPU-Hist/data/CPU-Hist-Min.txt" \
            using (('$Now'-$1)/60):2:x2tic(2) title "Average:" with impulses '\
 | gnuplot
