
set xlabel "Time (mm:ss)"
#set ylabel "Rate [bytes/s]"
#set y2label "Buffer size (1 second average) [bytes]"
set key left top

set lmargin 8
#set rmargin 10
#set size ratio .5

set style data linespoints

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"
set xtics 10

set logscale y
#set logscale y2
set yrange [100:20000000]
#set y2range [100:20000000]
#set ytics nomirror
#show ytics
#set y2tics axis in nomirror
#show y2tics


set terminal postscript eps color size 4, 2 "Helvetica" 16
set output "flow.eps"

plot \
   "reader.log" using 1:3 title "Rate limit (bytes/s)", \
   "reader.log" using 1:4 title "Rate (bytes/s)", \
   "reader.log" using 1:6 axes x1y1 title "Receive buffer (bytes)", \
   "writer.log" using 1:5 axes x1y1 title "Send buffer (bytes)"

#   "writer.log" using 1:3 title "Send rate", \
