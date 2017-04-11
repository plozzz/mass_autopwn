#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
apt-get install libpcap-dev tshark pyrit
mkdir wifite
cd wifite
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/reaver-wps/reaver-1.4.tar.gz
tar -xvf reaver-1.4.tar.gz
rm reaver-1.4.tar.gz
cd reaver-1.4/src/
./configure

... To be continued


wget https://raw.github.com/derv82/wifite/master/wifite.py
chmod +x wifite.py
./wifite.py
