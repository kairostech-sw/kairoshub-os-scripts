#!/bin/sh
WORKSPACE_DIR="/home/pi/workspace"
RELEASE_DIR=$WORKSPACE_DIR"/RELEASE"
BACKUP_DIR=$RELEASE_DIR"/BACKUP"
FILENAME_VERSION="hakairos-configuration.VERSION"
CURRENT_TIMESTAMP=`date +%s`
LOG_DIR=$WORKSPACE_DIR"/logs"
LOG_FILE="release_hakairos-configuration.log"

[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"

[ ! -f "$LOG_DIR/$LOG_FILE"] && touch $LOG_DIR/$LOG_FILE

prettyEchoMessage(){
        echo "$(date --date=now '+%Y-%m-%d:%H:%M') - $1" >> $LOG_DIR/$LOG_FILE
}

prettyEchoMessage "############################################################"
prettyEchoMessage "############################################################"
prettyEchoMessage " "

cd $RELEASE_DIR
SOFTWARE_VERSION=`cat $FILENAME_VERSION`

prettyEchoMessage "GETTING kairoshub configuration RELEASE"
REPO="https://github.com/kairostech-sw/kairoshub-configuration/releases/download/kairoshome-dev-latest/hakairos-configuration.zip"
ZIPFILE="hakairos-configuration-release.zip"
wget -c $REPO -O $ZIPFILE &&
prettyEchoMessage "UNPACKAGING ARCHIVE $ZIPFILE"
unzip $ZIPFILE &&

prettyEchoMessage "CURRENT SOFTWARE VERSION: $SOFTWARE_VERSION"
RELEASE_SOFTWARE_VERSION=`cat $RELEASE_DIR/hakairos-configuration/$FILENAME_VERSION`
prettyEchoMessage "RELEASE SOFTWARE VERSION: $RELEASE_SOFTWARE_VERSION"


if [ "$SOFTWARE_VERSION" = "$RELEASE_SOFTWARE_VERSION" ]; then
        prettyEchoMessage "SOFTWARE UP TO DATE"
        python /home/pi/workspace/hakairos-configuration/scripts/release.py "hakairos-configuration" "UP_TO_DATE"
else
        prettyEchoMessage "UPDATING SOFTWARE"
        prettyEchoMessage "BACKUP OLD SOFTWARE"
        BACKUP_FILE="hakairos-configuration-"$CURRENT_TIMESTAMP".tar.gz"
        tar -czvf $BACKUP_DIR/$BACKUP_FILE $WORKSPACE_DIR"/hakairos-configuration" &&
        
        prettyEchoMessage "STOPPING CONTAINER.."
        docker stop appdaemon
        
        prettyEchoMessage "MOOVING NEW SOFTWARE TO WORKSPACE"
        sudo rsync -a hakairos-configuration $WORKSPACE_DIR
        sleep 5
        
        prettyEchoMessage "PUBLISHING SOFTWARE MANIFEST"
        python /home/pi/workspace/hakairos-configuration/scripts/release.py "hakairos-configuration" $RELEASE_SOFTWARE_VERSION
        echo $RELEASE_SOFTWARE_VERSION | tee $FILENAME_VERSION #volutamente lasciata così
        
        prettyEchoMessage "REBOOTING CONTAINER.."
        docker start appdaemon

        #chmod +x $WORKSPACE_DIR"/hakairos-configuration/scripts/os/release_hakairos-configuration.sh"
        #chmod +x $WORKSPACE_DIR"/hakairos-configuration/scripts/os/release_kairoshub.sh"
fi;

prettyEchoMessage "CLEANING ENVIRONMENT..."
rm $RELEASE_DIR/$ZIPFILE
rm -rf $RELEASE_DIR/hakairos-configuration

prettyEchoMessage "END kairoshub configuration release script"
exit 0