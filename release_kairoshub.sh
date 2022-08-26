#!/bin/sh

CONTAINER_NAME="kairoshub"
WORKSPACE_DIR="/home/pi/workspace"
RELEASE_DIR=$WORKSPACE_DIR"/RELEASE"
BACKUP_DIR=$RELEASE_DIR"/BACKUP"
FILENAME_VERSION="kairoshub.VERSION"
CURRENT_TIMESTAMP=`date +%s`
LOG_DIR=$WORKSPACE_DIR"/logs"
LOG_FILE="release_kairoshub.log"

[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"

[ ! -f "$LOG_DIR/$LOG_FILE"] && touch $LOG_DIR/$LOG_FILE

prettyEchoMessage(){
        echo "$(date --date=now '+%Y-%m-%d %H:%M') - $1" >> $LOG_DIR/$LOG_FILE
}

prettyEchoMessage " "
prettyEchoMessage "############################################################"
prettyEchoMessage "############################################################"


cd $RELEASE_DIR
SOFTWARE_VERSION=`cat $FILENAME_VERSION`

prettyEchoMessage "GETTING kairoshub RELEASE"
REPO="https://github.com/kairostech-sw/kairoshub/releases/download/kairoshome-dev-latest/kairoshub.zip"
ZIPFILE="kairoshub-relase.zip"
wget -c $REPO -O $ZIPFILE &&
prettyEchoMessage "UNPACKAGING ARCHIVE $ZIPFILE"
unzip $ZIPFILE &&

prettyEchoMessage "CURRENT SOFTWARE VERSION: $SOFTWARE_VERSION"
RELEASE_SOFTWARE_VERSION=`cat $RELEASE_DIR/kairoshub/$FILENAME_VERSION`
prettyEchoMessage "RELEASE SOFTWARE VERSION: $RELEASE_SOFTWARE_VERSION"

if [ "$SOFTWARE_VERSION" = "$RELEASE_SOFTWARE_VERSION" ]; then
        prettyEchoMessage "SOFTWARE UP TO DATE"
        python /home/pi/workspace/hakairos-configuration/scripts/release.py "kairoshub" "UP_TO_DATE"
else
        { #try
                prettyEchoMessage "UPDATING SOFTWARE"
                prettyEchoMessage "BACKUP OLD SOFTWARE"
                BACKUP_FILE="kairoshub-"$CURRENT_TIMESTAMP".tar.gz"
                tar -czvf $BACKUP_DIR/$BACKUP_FILE $WORKSPACE_DIR"/kairoshub" &&

                prettyEchoMessage "STOPPING CONTAINER..."
                docker stop $CONTAINER_NAME
                
                prettyEchoMessage "MOOVING NEW SOFTWARE TO WORKSPACE"
                sudo rsync -a kairoshub $WORKSPACE_DIR
                sleep 5
                
                prettyEchoMessage "PUBLISHING SOFTWARE MANIFEST $RELEASE_SOFTWARE_VERSION"
                python /home/pi/workspace/hakairos-configuration/scripts/release.py "kairoshub" $RELEASE_SOFTWARE_VERSION
                echo $RELEASE_SOFTWARE_VERSION | tee $FILENAME_VERSION #lasciare così
                
                prettyEchoMessage "REBOOTING CONTAINER.."
                docker restart $CONTAINER_NAME

        } || { # catch
        
                msg = "An error is occourred on releasing kairoshub. Fallingback into mainteneance mode.."
                prettyEchoMessage  msg
                python /home/pi/workspace/hakairos-configuration/scripts/mainteneance.py "ON" msg
        }
fi;

prettyEchoMessage "CLEANING ENVIRONMENT..."
rm $RELEASE_DIR/$ZIPFILE
rm -rf $RELEASE_DIR/kairoshub

echo "END kairoshub release script"
exit 0