#!/bin/sh

WORKSPACE_DIR="/home/pi/workspace"
LOG_DIR=$WORKSPACE_DIR"/logs"
LOG_OS_SCRIPT_FILE="restore_os_scrips.log"
SCRIPTS_DIR=$WORKSPACE_DIR"/scripts"

[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"

[ ! -f "$LOG_DIR/$LOG_OS_SCRIPT_FILE"] && touch $LOG_DIR/$LOG_OS_SCRIPT_FILE

prettyEchoMessage(){
        echo "$(date --date=now '+%Y-%m-%d %H:%M') - $1" >> $LOG_DIR/$LOG_OS_SCRIPT_FILE
}

cd $SCRIPTS_DIR
prettyEchoMessage "############################################################"
prettyEchoMessage "############ RESTORING KAIROSHUB RELEASE SCRIPT ############"

REPO="https://github.com/kairostech-sw/kairoshub-os-scripts/releases/download/kairoshome-latest/release_kairoshub.sh"
RELEASE_FILE="release_kairoshub.sh"
RELEASE_FILE_BKP="release_kairoshub.sh.bkp"
RELEASE_FILE_TO_CHECK="release_kairoshub.sh.check"
{ # try
        wget -c $REPO -O $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK &&

        prettyEchoMessage "comparing $RELEASE_FILE and $RELEASE_FILE_TO_CHECK files"
        if cmp --silent -- $SCRIPTS_DIR/$RELEASE_FILE $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK; then
                prettyEchoMessage "Files are identical, skipping.."
        else
                prettyEchoMessage "The files are divergent, a backup of the current file will be created"
                [ -f "$SCRIPTS_DIR/$RELEASE_FILE_BKP"] && rm $SCRIPTS_DIR/$RELEASE_FILE_BKP

                #rename old file
                mv $SCRIPTS_DIR/$RELEASE_FILE $SCRIPTS_DIR/$RELEASE_FILE_BKP &&

                #moving new file
                mv $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK $SCRIPTS_DIR/$RELEASE_FILE &&

                #change permission file
                chmod +x $SCRIPTS_DIR/$RELEASE_FILE &&

                prettyEchoMessage "kairoshub release script restored. Script invoking.."
        fi

} || { # catch
        
        prettyEchoMessage "An error is occourred on restoring kairoshub release script." 
}

rm $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK

prettyEchoMessage "############                 OK                 ############"
prettyEchoMessage "############################################################"

prettyEchoMessage " "

prettyEchoMessage "############################################################"
prettyEchoMessage "##### RESTORING KAIROSHUB CONFIGURATION RELEASE SCRIPT #####"

REPO="https://github.com/kairostech-sw/kairoshub-os-scripts/releases/download/kairoshome-latest/release_hakairos-configuration.sh"
RELEASE_FILE="release_hakairos-configuration.sh"
RELEASE_FILE_BKP="release_hakairos-configuration.sh.bkp"
RELEASE_FILE_TO_CHECK="release_hakairos-configuration.sh.check"
{ # try
        wget -c $REPO -O $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK &&

        prettyEchoMessage "comparing $RELEASE_FILE and $RELEASE_FILE_TO_CHECK files"
        if cmp --silent -- $SCRIPTS_DIR/$RELEASE_FILE $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK; then
                prettyEchoMessage "Files are identical, skipping.."
        else
                prettyEchoMessage "The files are divergent, a backup of the current file will be created"
                [ -f "$SCRIPTS_DIR/$RELEASE_FILE_BKP"] && rm $SCRIPTS_DIR/$RELEASE_FILE_BKP

                #rename old file
                mv $SCRIPTS_DIR/$RELEASE_FILE $SCRIPTS_DIR/$RELEASE_FILE_BKP &&

                #moving new file
                mv $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK $SCRIPTS_DIR/$RELEASE_FILE &&

                #change permission file
                chmod +x $SCRIPTS_DIR/$RELEASE_FILE &&
                
                prettyEchoMessage "kairoshub configuration release script restored. Script invoking.."
        fi

} || { # catch
       prettyEchoMessage "An error is occourred on restoring kairoshub configuration release script." 
}

rm $SCRIPTS_DIR/$RELEASE_FILE_TO_CHECK

prettyEchoMessage "#####                        OK                        #####"
prettyEchoMessage "############################################################"

prettyEchoMessage "END restore os scripts"
exit 0