#!/bin/bash
#script to start the minedocker server

set -e

QUIET=false
#SFLOG="/start.log"

timestamp() {
	date +"%Y-%m-%d %T"
}

#screen/file logger
sflog() {
	
	if [ ! -z ${1+x} ]; then
		message=$1
	else
		return 1;
	fi
	if ! $($QUIET); then
		echo "${message}"
	fi
	if [ ! -z ${SFLOG+x} ]; then		
		if [ -f ${SFLOG} ] || [ ! -e ${SFLOG} ]; then
			echo "$(timestamp) ${message}" >> ${SFLOG}
		fi
	fi
}


sflog "Getting last minecraft version from amazon s3"
VER=$(wget -q -O - https://s3.amazonaws.com/Minecraft.Download/versions/versions.json | jsawk -n 'out(this.latest.release)')


MCDIR="/minecraft"
MCJAR="$MCDIR/minecraft-server.jar"

if [ -e $MCJAR ]; then
  rm -rf $MCJAR &> /dev/null
fi

sflog "Downloading https://s3.amazonaws.com/Minecraft.Download/versions/$VER/minecraft_server.$VER.jar"
wget -q -O $MCJAR https://s3.amazonaws.com/Minecraft.Download/versions/$VER/minecraft_server.$VER.jar &> /dev/null

echo "eula=true" > $MCDIR/eula.txt

chown -R minecraft:minecraft $MCDIR &> /dev/null

sflog "Starting minecraft v.$VER..."
cd $MCDIR
exec sudo -E -u minecraft java -Xmx4000M -Xms4000M -jar $MCJAR

sflog "Exiting container..."
