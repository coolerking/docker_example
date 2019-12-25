#!/bin/sh
/bin/cp ./apt.conf /etc/apt/apt.conf
/usr/bin/apt-get update && /usr/bin/apt-get -y upgrade && /usr/bin/apt-get install -y aptitude
/usr/bin/aptitude -y install vim git subversion curl wget
/bin/ln -s /notebooks/work ${HOME}/work
/bin/ln -s /notebooks/share ${HOME}/share
/bin/cp ./curlrc.txt ~/.curlrc
/usr/bin/git config --global http.proxy http://solidproxy.exa-corp.co.jp:8080/
/usr/bin/git config --global https.proxy http://solidproxy.exa-corp.co.jp:8080/
