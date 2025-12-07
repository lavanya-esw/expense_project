#!/bin/bash
#colour codes
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NO_COLOR="\e[37m"

START_TIME=$(date +%s)
LOG_DIR=/var/log/expense
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}.log
mkdir -p $LOG_DIR

#To check root user or not
ROOT_USER=$(id -u)
if [ $ROOT_USER -ne 0 ]; then
    echo "Pease run the script under root privilages"
    exit 1
fi
VALIDATE()
{
    if [ $1 -ne 0 ]; then
        echo -e "$2...$RED FAILURE $NO_COLOR"
    else
        echo -e "$2...$GREEN SUCCESS $NO_COLOR"
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? nable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL Server"
systemctl start mysqld   &>>$LOG_FILE
VALIDATE $? "Starting MySQL Server"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting up Root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"