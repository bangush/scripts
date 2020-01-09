#!/bin/bash
# requires activesync.txt available at:
# https://mail.icewarp.cz/webdav/ticket/eJwNy0EOhCAMAMDf9KZbKw1w6NUP.IICZWNMNFE06.,duc9XWF0cCpY4qkGVeb,SfjyQZYJT2CeqgRHNEA7paHDeMfrgwASWfyZS5opa.KO5Lbedz5b79muwCuUQNOKY0gsMHR5N/activesync.txt

STATE_OK=0 
STATE_WARNING=1 
STATE_CRITICAL=2 
STATE_UNKNOWN=3 
STATE_DEPENDENT=4 
DBUSER="discover";
DBPASS="discover";
DBHOST="discover";
DBPORT="discover";
DBNAME="discover";
USER="discover";
PASS="discover";
HOST="127.0.0.1";
aURI="discover";
aTYPE="discover";
aKey="discover";
FOLDER="INBOX";

declare DBUSER=$(/opt/icewarp/tool.sh get system C_ActiveSync_DBUser | sed -r 's|^C_ActiveSync_DBUser: (.*)$|\1|')
declare DBPASS=$(/opt/icewarp/tool.sh get system C_ActiveSync_DBPass | sed -r 's|^C_ActiveSync_DBPass: (.*)$|\1|')
read DBHOST DBPORT DBNAME <<<$(/opt/icewarp/tool.sh get system C_ActiveSync_DBConnection | sed -r 's|^C_ActiveSync_DBConnection: mysql:host=(.*);port=(.*);dbname=(.*)$|\1 \2 \3|')
read -r USER aURI aTYPE aVER aKEY <<<$(echo "select * from devices order by last_sync asc\\G" |  mysql -u ${DBUSER} -p${DBPASS} -h ${DBHOST} -P ${DBPORT} ${DBNAME} | tail -24 | egrep "user_id:|uri:|type:|protocol_version:|synckey:" | xargs -n1 -d'\n' | tr -d '\040\011\015\012' | sed -r 's|^user_id:(.*)uri:(.*)type:(.*)protocol_version:(.*)synckey:(.*)$|\1 \2 \3 \4 \5|')
/opt/icewarp/tool.sh set system C_Accounts_Policies_Pass_DenyExport 0
/opt/icewarp/tool.sh set system C_Accounts_Policies_Pass_AllowAdminPass 1
declare PASS=$(/opt/icewarp/tool.sh export account "${USER}" u_password | sed -r 's|^.*,(.*),$|\1|')
/opt/icewarp/tool.sh set system C_Accounts_Policies_Pass_DenyExport 1
/opt/icewarp/tool.sh set system C_Accounts_Policies_Pass_AllowAdminPass 0

HOST="127.0.0.1"
aURI="000Prdel000"
aTYPE="IceWarpAnnihilator"
declare -i aSYNCKEY=${aKEY};

result=`/usr/bin/curl -k --basic --user "$USER:$PASS" -H "Expect: 100-continue" -H "Host: $HOST" -H "MS-ASProtocolVersion: ${aVER}" -H "Connection: Keep-Alive" -A "${aTYPE}" --data-binary @/root/activesync.txt -H "Content-Type: application/vnd.ms-sync.wbxml" "https://$HOST/Microsoft-Server-ActiveSync?User=$USER&DeviceId=$aURI&DeviceType=$aTYPE&Cmd=FolderSync" | strings` 

if [[ $result == *$FOLDER* ]] 
then 
echo "OK" 
exit $STATE_OK 
else 
echo "FAIL" 
exit $STATE_CRITICAL 
fi
