#!/bin/sh
TARGET_ENV=$1
WORKSPACE_DIR="/home/pi/workspace"
RELEASE_DIR=$WORKSPACE_DIR"/RELEASE"
BACKUP_DIR=$RELEASE_DIR"/BACKUP"
FILENAME_VERSION="hakairos-configuration.VERSION"
CURRENT_TIMESTAMP=`date +%s`
LOG_DIR=$WORKSPACE_DIR"/logs"
LOG_FILE="release_hakairos-configuration.log"

[ -z "$TARGET_ENV" ] && exit "Empty TARGET_ENV, please provide one."

[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"

[ ! -f "$LOG_DIR/$LOG_FILE" ] && touch $LOG_DIR/$LOG_FILE

prettyEchoMessage(){
        echo "$(date --date=now '+%Y-%m-%d:%H:%M') - $1" >> $LOG_DIR/$LOG_FILE
}

prettyEchoMessage " "
prettyEchoMessage "############################################################"
prettyEchoMessage "############################################################"

cd $RELEASE_DIR
[ ! -f $FILENAME_VERSION ] && touch $FILENAME_VERSION #runs only first time
SOFTWARE_VERSION=`cat $FILENAME_VERSION`

prettyEchoMessage "GETTING kairoshub configuration RELEASE"
REPO="https://github.com/kairostech-sw/kairoshub-configuration/releases/download/$TARGET_ENV/hakairos-configuration.zip"
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
        { # try
                prettyEchoMessage "UPDATING SOFTWARE"
                prettyEchoMessage "BACKUP OLD SOFTWARE"
                BACKUP_FILE="hakairos-configuration-"$CURRENT_TIMESTAMP".tar.gz"
                tar -czvf $BACKUP_DIR/$BACKUP_FILE $WORKSPACE_DIR"/hakairos-configuration" &&
                
                prettyEchoMessage "STOPPING APPDAEMON CONTAINER.."
                docker stop appdaemon

                prettyEchoMessage "STOPPING KAIROSHUB CONTAINER.."
                docker stop kairoshub
                
                prettyEchoMessage "MOOVING NEW SOFTWARE TO WORKSPACE"
                sudo rsync -a hakairos-configuration $WORKSPACE_DIR
                sleep 5
                
                prettyEchoMessage "PUBLISHING SOFTWARE MANIFEST"
                python /home/pi/workspace/hakairos-configuration/scripts/release.py "hakairos-configuration" $RELEASE_SOFTWARE_VERSION
                echo $RELEASE_SOFTWARE_VERSION | tee $FILENAME_VERSION #volutamente lasciata così
                
                prettyEchoMessage "REBOOTING APPDAEMON CONTAINER.."
                docker start appdaemon

                prettyEchoMessage "REBOOTING KAIROSHUB CONTAINER.."
                docker start kairoshub

                prettyEchoMessage "RESTARTING KAIROSHUB ASSISTANCE SERVICE"
                sudo service kairoshub-assistance stop
                sudo service kairoshub-assistance start

        } || { # catch
        
                prettyEchoMessage  "An error is occourred on releasing kairoshub configuration. Fallingback into mainteneance mode.."
                python /home/pi/workspace/hakairos-configuration/scripts/mainteneance.py "ON" "An error is occourred on releasing kairoshub configuration. Fallingback into mainteneance mode.."
        }

fi;

prettyEchoMessage "CLEANING ENVIRONMENT..."
rm $RELEASE_DIR/$ZIPFILE
rm -rf $RELEASE_DIR/hakairos-configuration

prettyEchoMessage "END kairoshub configuration release script"
exit 0