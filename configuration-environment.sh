#!/bin/sh
TARGET_ENV=$1
WORKSPACE_DIR="/home/pi/workspace"
LOG_DIR=$WORKSPACE_DIR"/logs"
SCRIPTS_DIR=$WORKSPACE_DIR"/scripts"
RESTORE_SCRIPT=$SCRIPTS_DIR/"restore_os_scripts.sh"
THIS_SCRIPT=$WORKSPACE_DIR/"configuration-environment.sh"
KAIROSCONFIGURATION_RELEASE_SCRIT=$SCRIPTS_DIR/"release_hakairos-configuration.sh"
KAIROSHUB_RELEASE_SCRIPT=$SCRIPTS_DIR/"release_kairoshub.sh"

[ -z "$TARGET_ENV" ] && exit "Empty TARGET_ENV, please provide one."

LOG_FILE="startup-environment.log"

REPO="https://github.com/kairostech-sw/kairoshub-os-scripts/releases/download/$TARGET_ENV/restore_os_scripts.sh"

cd $WORKSPACE_DIR

[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR" &&
[ ! -d "$SCRIPTS_DIR" ] && mkdir -p "$SCRIPTS_DIR" &&

[ ! -f "$LOG_DIR/$LOG_OS_SCRIPT_FILE" ] && touch $LOG_DIR/$LOG__FILE

[ ! -f "$SCRIPTS_DIR/release_kairoshub.sh" ] && touch $SCRIPTS_DIR/"release_kairoshub.sh"
[ ! -f "$SCRIPTS_DIR/release_hakairos-configuration.sh" ] && touch $SCRIPTS_DIR/"release_hakairos-configuration.sh"


prettyEchoMessage(){
        echo "$(date --date=now '+%Y-%m-%d:%H:%M') - $1" >> $LOG_DIR/$LOG_FILE
}

echo "LOGS will be written on $LOG_DIR/$LOG_OS_SCRIPT_FILE"

prettyEchoMessage "############################################################"
prettyEchoMessage "############ CONFIGURATION ENVIRONMENT SCRIPT ##############"

[ -f "$RESTORE_SCRIPT" ] && rm $RESTORE_SCRIPT
prettyEchoMessage "Downloading restore script from repository: $REPO"
wget $REPO -O $RESTORE_SCRIPT &&

prettyEchoMessage "Changing permission to restore script"
chmod +x $RESTORE_SCRIPT &&

prettyEchoMessage "Adding crontab schedulation for $RESTORE_SCRIPT every day at 02:00 AM"
sudo crontab -l > crontobeupdated
echo "0 02 * * * $RESTORE_SCRIPT $TARGET_ENV" > crontobeupdated
prettyEchoMessage "Adding crontab schedulation $THIS_SCRIPT every day at 01:00 AM"
echo "0 01 * * * $THIS_SCRIPT $TARGET_ENV" >> crontobeupdated
prettyEchoMessage "Adding crontab schedulation $KAIROSHUB_RELEASE_SCRIPT every 15 days at 02:10 AM"
echo "10 02 */15 * * $KAIROSHUB_RELEASE_SCRIPT $TARGET_ENV" >> crontobeupdated
prettyEchoMessage "Adding crontab schedulation $KAIROSCONFIGURATION_RELEASE_SCRIT every 15 days at 02:05 AM"
echo "05 02 */15 * * $KAIROSCONFIGURATION_RELEASE_SCRIT $TARGET_ENV" >> crontobeupdated

sudo crontab -u root crontobeupdated
rm crontobeupdated

prettyEchoMessage "reloading cron service.."
sudo service cron reload

prettyEchoMessage "END"
exit 0