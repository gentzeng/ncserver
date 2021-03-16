#!/bin/bash

#Reset colors and font style
N='\033[0;0m'

#normal colors
BlkN='\033[0;30m'
RedN='\033[0;31m'
GreN='\033[0;32m'
YelN='\033[0;33m'
BluN='\033[0;34m'
PurN='\033[0;35m'
CyaN='\033[0;36m'
WhiN='\033[0;37m'

#Light/Bold colors
BlkB='\033[1;30m'
RedB='\033[1;31m'
GreB='\033[1;32m'
YelB='\033[1;33m'
BluB='\033[1;34m'
PurB='\033[1;35m'
CyaB='\033[1;36m'
WhiB='\033[1;37m'

#Faint colors
BlkF='\033[2;30m'
RedF='\033[2;31m'
GreF='\033[2;32m'
YelF='\033[2;33m'
BluF='\033[2;34m'
PurF='\033[2;35m'
CyaF='\033[2;36m'
WhiF='\033[2;37m'

#shortened color variables for helppage
R=${RedB}
G=${GreB}
#Commandline args variables
argNum=0
args=()
optNum=0
opts=()

#Flags
flagDryRun=false
flagVerbose=false
flagDebug=false

#Variables
fileNc=""
sumMd5=""
sumSha1=""
sumSha256=""
sumSha512=""
port=2222

if [ "$#" -lt 0 ]; then
  exit
fi

#--scan for Arguments and options-----------------------------------------------
for i in "$@"; do
  if [[ $i == -* ]]; then
    opts+=("$i");
    ((++optNum));
  else
    args+=("$i");
    ((++argNum));
  fi
done

#--Setting Flags----------------------------------------------------------------
for i in "${opts[@]}"; do
  case $i in
    --noop) ####################################################################
      exit
      ;;
    -v|--verbose) ##############################################################
      flagVerbose=true
      continue
      ;;
    --dryrun) ##################################################################
      flagDryRun=true
      continue
      ;;
    --debug) ###################################################################
      flagDebug=true
      continue
      ;;
  esac
done

#--Setting Args-----------------------------------------------------------------
#Take the first arg as file to be sent per nc
if [[ ${#args[@]} == 1 ]]; then
  fileNc=$args
else
  fileNc=${args[0]}
fi

#--Print script intro-----------------------------------------------------------
echo -e "${RedB} --- NC Server Script --- ${N}"
echo ""

#--Print various fingerprints and IP address------------------------------------
sumMd5=$(md5sum ./${fileNc})
if [[ $flagDebug == true ]]; then
  echo "calculated md5sum"
fi
sumSha1=$(sha1sum -b ./${fileNc})
if [[ $flagDebug == true ]]; then
  echo "calculated sha1sum"
fi
sumSha256=$(sha256sum -b ./${fileNc})
if [[ $flagDebug == true ]]; then
  echo "calculated sha256sum"
fi
sumSha512=$(sha512sum -b ./${fileNc})
if [[ $flagDebug == true ]]; then
  echo "calculated sha512sum"
fi

echo -e "Checksums of ${fileNc}:"
echo -e "md5    = ${GreB}$sumMd5${N}"
echo -e "sha1   = ${BluB}$sumSha1${N}"
echo -e "sha256 = ${PurB}$sumSha256${N}"
echo -e "sha512 = ${PurB}$sumSha512${N}"
echo ""
echo -e "ipAddr = ${CyaB}$( ip addr | \
  grep 'state UP' -A2 | \
  tail -n1 | \
  awk '{print $2}' | \
  cut -f1  -d'/' \
)${N}" 
echo -e "port   = ${CyaB}${port}${N}"
echo ""

#--Send file over nc server-----------------------------------------------------
httpMsg="HTTP/1.0 200 OK \r\nContent-Disposition: attachment; filename=\"${fileNc}\"\r\n\r\n"
if [[ $flagDryRun == true ]]; then
  echo -e -n $httpMsg
else
    echo -e -n "$httpMsg" >&1 | cat - ./${fileNc} | nc -q0 -l ${port}
fi
