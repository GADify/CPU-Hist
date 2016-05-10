#!/bin/bash
#
# Gary A. Donahue 2014
#
# impulses, lines
Now=$(date +%s)
# Get Length, Width, ($1, $2) else assign them
WIDTH=${1-800}
LENGTH=${2-300}
echo '                                     \
   set term png enhanced medium   \
           xFFFFFF \
           size ' $WIDTH','$LENGTH ';          \
   set output "CPU-Hist-Min.png";          \
   set title "CPU Utilization - 3 Hours";  \
   set xlabel "Minutes";                   \
   set yrange [0:100];                     \
   set xrange [0:180];                     \
   set xtics axis nomirror;                \
   set ytics 0,25,100 nomirror;            \
   set key on;                            \
   set style fill solid 1.0;  \
   plot "/opt/CPU-Hist/data/CPU-Hist-Min.txt" using (('$Now'-$1)/60):3 title "Peak:" w
ith lp , "/opt/CPU-Hist/data/CPU-Hist-Min.txt" using (('$Now'-$1)/60):2:x2tic(2) title
 "Average:" with boxes '\
 | gnuplot

