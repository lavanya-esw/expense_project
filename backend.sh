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
MONGODB_SERVER_IPADDRESS="mongodb.awsdevops.fun"
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

cp $SCRIPT_DIR/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copy systemctl service"

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable nodejs"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enable nodejs"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "install nodejs"

id expense
if [ $? -ne 0 ]; then
   echo "creating expense user"
    useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense
    VALIDATE $? "Creating system user"
else
    echo -e "expense user is already created.....$Y SKIPPING $N"
fi  

mkdir -p /app 
VALIDATE $? "create app folder"

curl -o /tmp/backend.zip https://expense-joindevops.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "unzip backend"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "install mysql server"

mysql -h mysql.awsdevops.fun -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE


systemctl daemon-reload
systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enable backend"
systemctl restart backend &>>$LOG_FILE
VALIDATE $? "restart backend"