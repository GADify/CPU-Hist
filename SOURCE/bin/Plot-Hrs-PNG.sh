#!/bin/bash
#
# Gary A. Donahue 2014
#
# impulses, lines
Now=$(date +%s)
# Get Length, Width, ($1, $2) else assign them
WIDTH=${1-800}
LENGTH=${2-300}
echo '                                    \
   set term png enhanced medium   \
           xFFFFFF \
           size ' $WIDTH','$LENGTH ';          \
   set output "CPU-Hist-Hrs.png";          \
   set title "CPU Utilization - 3 Days";  \
   set xlabel "Hours";                    \
   set yrange [0:100];                    \
   set xrange [0:72];                     \
   set xtics axis nomirror;               \
   set ytics axis out nomirror 0,25,100 ; \
   set key on;                           \
   set style fill solid 1.0;  \
   plot "/opt/CPU-Hist/data/CPU-Hist-Hrs.txt" using (('$Now'-$1)/3600):3 title "Peak:"
with lp , "/opt/CPU-Hist/data/CPU-Hist-Hrs.txt" using (('$Now'-$1)/3600):2:x2tic(2) ti
tle "Average:" with boxes '\
 | gnuplot

