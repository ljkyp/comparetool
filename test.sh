#!/bin/sh
 tmpSize=`df -T /tmp | grep tmp | awk '{print $3}' | cut -d '.' -f 1`
 echo 'The size of /tmp filesystem '${tmpSize}' GB'
  
  case ${tmpSize} in
     0)
        chfs -a size=+2G /tmp
        echo 'The size of /tmp filesystem is increased 2GB.'
        ;;
     1)
        chfs -a size=+1G /tmp
        echo 'The size of /tmp filesystem is increased 1GB.'
        ;;
     *)
        echo 'The size of /tmp filesystem is equal or greater than 2GB.'
        ;;
  esac