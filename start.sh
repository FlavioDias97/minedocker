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
exec sudo -E -u minecraft java -Xms10G -Xmx10G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=8 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:MaxTenuringThreshold=1 -jar $MCJAR

sflog "Exiting container..."
