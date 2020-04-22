#!/bin/sh
# 入力ファイル（現または新）のフルパス
IN_FILE=$1
#出力ファイルのフルパス
OUT_FILE=$2
#ヘッダ有無
HEAD_FLAG=$3
#外部定義(①ファイルレイアウトのパラメータファイル)
FILE_LAYOUT=$4
#外部定義(②ソートキー)
SORT_FLAG=$5
#外部定義(③除外する項目のパラメータファイル)
NOJOKI_ITEM=$6
#項目数
STR_COL=2
END_COL=6
#Pattern file 比較対象項目
COMPARE_ITEM
#ファイルポマード
FILE_TYPE=""


echo ${IN_FILE} | grep -i "csv" | 2>/dev/null
if [[ $? -eq 0 ]]; then
   FILE_TYPE=CSV
else
   FILE_TYPE=TXT
fi
echo "file type : " ${FILE_TYPE}

CUTDATA=""
CUTDATA2=""
ROWCNT=0 
while read line 
do
  ROWCNT=$(($ROWCNT + 1))
  #length
  if [[ ${ROWCNT} -eq 3 ]]; then
    COLCNT=0
    CUTDATA=''
    CUTDATA2=''
    MAX_COL=5
    for (( var=$STR_COL; var<=$END_COL; var++ ))
    do 
        CUTDATA2=$(echo $line | cut -f $var -d ',') 
        if [[ $CUTDATA2 ]]; then
            if [[ ${COLCNT} -eq 0 ]]; then
                CUTDATA=$CUTDATA$CUTDATA2
            else
                CUTDATA=$CUTDATA','$CUTDATA2
            fi
        fi
        COLCNT=$(($COLCNT + 1))
        
        # CUTDATA2=$line" | cut -f 1 -d','" 
        # echo $CUTDATA2
        # echo $line | cut -f $var -d ','

    done
    echo 'length: '$CUTDATA
    # CUTDATA2='1,2,3'
    # echo $line | cut -f  ${CUTDATA2} -d ','
  fi 
  #比較対象、4番目　２項目から
  if [[ ${ROWCNT} -eq 4 ]]; then
    COLCNT=1
    CUTDATA=''
    CUTDATA2=''
    for (( var=$STR_COL; var<=$END_COL; var++ ))
    do 
        CUTDATA2=$(echo $line | cut -f $var -d ',') 
        if [[ ${CUTDATA2} ]]; then
            if [[ $(echo ${CUTDATA2}) -eq 1 ]]; then
                if [[ ${COLCNT} -eq 1 ]]; then
                    CUTDATA2=$COLCNT
                else
                    CUTDATA2=','$COLCNT
                fi
                CUTDATA=$CUTDATA$CUTDATA2
            fi
        fi
        COLCNT=$(($COLCNT + 1))

    done
    echo '比較対象: '$CUTDATA

    # COLCNT=1
    # CUTDATA=''
    # CUTDATA2=''
    # CUTDATA2=$(echo $line | cut -f 2 -d ',') 
    # echo ${CUTDATA2}
    # while true
    # do
    # echo ${CUTDATA2}
    #     CUTDATA2=$(echo $line | cut -f $COLCNT -d ',') 
    #     if [[ ${CUTDATA2} ]]; then
    #     echo ${CUTDATA2}
    #         if [[ $(echo ${CUTDATA2}) -eq 1 ]]; then
    #             if [[ ${COLCNT} -eq 1 ]]; then
    #                 CUTDATA2=$COLCNT
    #             else
    #                 CUTDATA2=','$COLCNT
    #             fi
    #             CUTDATA=$CUTDATA$CUTDATA2
    #         fi
    #     else
    #         break
    #     fi
    #     COLCNT=$(($COLCNT + 1))
    #     CUTDATA2=$(echo $line | cut -f $COLCNT -d ',') 
    # done
    # echo '比較対象: '$CUTDATA
  
    # CUTDATA2='1,2,3'
    # echo $line | cut -f  ${CUTDATA2} -d ','
  fi 
done < ${IN_FILE}




# while read line 
# do
#   ROWCNT=$(($ROWCNT + 1))
#   if [[ ${ROWCNT} -eq 3 ]]; then
# 	echo ${line} | cut -f 1-3 -d ',' 
# 	echo ${line} | awk '{print $1}'
#   fi 
# done < ${IN_FILE}