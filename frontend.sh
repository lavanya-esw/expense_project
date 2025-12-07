#!/bin/bash
#colour codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"
B="\e[34m"

SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
LOG_DIR=/var/log/shell_roboshop_project
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
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
        echo -e "$2...$R FAILURE $N"
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "start Nginx"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend"

rm -rf /etc/nginx/default.d/expense.conf
cp $SCRIPT_DIR/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copying expense.conf"

systemctl restart nginx 
VALIDATE $? "Restarting Nginx"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e " $B script executed in $TOTAL_TIME seconds $N"
