#!/bin/sh  
#

APP_HOME=~/bin

#启动的程序名称
APP_NAME=lightos

PROFILE=dev,swagger

LOG_PATH=~/bin/logs
LOG_FILE=lightos

#java虚拟机启动参数
JAVA_OPTS="-Xmx1048m -Xms512m"

#**************************
#(函数)判断程序是否已启动
#初始化psid变量
#****************************
psid=0

checkpid() {
   JPID=$(ps -ef | grep java.*$APP_NAME.*.war | grep -v grep | awk '{ print $2 }')
   if [ -z "$JPID" ]
   then
      psid=0
   else
      psid=$JPID
   fi
}  

#**************************
#启动程序
#****************************
start() {
   checkpid

   if [ $psid -ne 0 ]; then
      echo "================================"
      echo "warn: $APP_NAME already started! (pid=$psid)"
      echo "================================"
   else
      echo -n "Starting $APP_NAME ..."

      nohup java -jar $APP_HOME/$APP_NAME*.war $JAVA_OPTS --spring.profiles.active=$PROFILE >/dev/null 2>&1 &
      checkpid
      if [ $psid -ne 0 ]; then
         echo "(pid=$psid) [OK]"
      else
         echo "[Failed]"
      fi
   fi
}

#*****************************
#停止程序
#*****************************
stop() {
	checkpid
   
   if [ $psid -ne 0 ]; then
      echo -n "Stopping $APP_NAME ...(pid=$psid) "
      kill  $psid
      if [ $? -eq 0 ]; then
         echo "[OK]"
      else  
         echo "[Failed]"
      fi  
  
      checkpid  
      if [ $psid -ne 0 ]; then  
      	 kill -9 $psid
      else
         echo "[force stop OK]"
      fi  
      
      checkpid  
      if [ $psid -ne 0 ]; then  
      	 stop    
      fi 
   else  
      echo "================================"  
      echo "warn: $APP_NAME is not running"  
      echo "================================"  
   fi  
}  
  
#****************************
#检查程序运行状态
#****************************
status() {  
   checkpid  
  
   if [ $psid -ne 0 ];  then  
      echo "$APP_NAME is running! (pid=$psid)"  
   else  
      echo "$APP_NAME is not running"  
   fi  
}  

#********************************
#读取脚本的第一个参数($1)，进行判断  
#参数取值范围：{start|stop|restart|status}  
###################################  
case "$1" in
   'start')
      start
      ;;
   'stop')
     stop
     ;;
   'restart')
     stop
     start
     ;;
   'status')
     status
     ;;
  *)
     echo "Usage: $0 {start|stop|restart|status}"
     exit 1
esac
exit 0

