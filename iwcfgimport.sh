cfgImportFile=/root/cfgexport.cf
for I in orderId superPass gwSuperPass accStorageMode mailPath archivePath accDbConn dcDbConn gwDbConn asDbConn;
  do
    val="$(egrep "${I}" "${cfgImportFile}" | awk '{print $2}')";
    case "${I}" in
      orderId) echo "Activate using /opt/icewarp/wizard.sh using OrderID: "${val}""
      ;;
      superPass) /opt/icewarp/tool.sh set system C_Accounts_Policies_SuperUserPassword "${val}"
      ;;
      gwSuperPass) /opt/icewarp/tool.sh set system C_GW_SuperPass "${val}"
      ;;
      accStorageMode) /opt/icewarp/tool.sh set system C_System_Storage_Accounts_StorageMode "${val}"
      ;;
      mailPath) /opt/icewarp/tool.sh set system C_System_Storage_Dir_MailPath "${val}"
      ;;
      archivePath) /opt/icewarp/tool.sh set system C_System_Tools_AutoArchive_Path "${val}"
      ;;
      accDbConn) /opt/icewarp/tool.sh set system c_system_storage_accounts_odbcconnstring "${val}"
      ;;
      dcDbConn) /opt/icewarp/tool.sh set system c_accounts_global_accounts_directorycacheconnectionstring "${val}"
      ;;
      gwDbConn) /opt/icewarp/tool.sh set system c_gw_connectionstring "${val}"
      ;;
      asDbConn) /opt/icewarp/tool.sh set system c_as_challenge_connectionstring "${val}"
      ;;
    esac
  done
  
