PlotAllPNGs.sh

#/bin/bash

/opt/CPU-Hist/bin/Plot-Sec-PNG.sh
/opt/CPU-Hist/bin/Plot-Min-PNG.sh
/opt/CPU-Hist/bin/Plot-Hrs-PNG.sh

# Place images in directroy for EOS nginx WebServer
if [[ -e /etc/Eos-release ]]; then
   EOS='yes'
   sudo cp *.png /usr/share/nginx/html/apps/CPU-Hist/
else
   EOS='no'
fi



