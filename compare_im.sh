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
#Pattern file 条件チェック


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
  #比較対象、4番目　２項目から
  if [[ ${ROWCNT} -eq 4 ]]; then
    COLCNT=0
    CUTDATA=''
    CUTDATA2=''
    for var in {2..100}
    do 
        CUTDATA2=$(echo $line | cut -f $var -d ',') 
        if [[ $CUTDATA2 ]]; then
            if [[ ${COLCNT} -eq 0 ]]; then
                CUTDATA2=$var
            else
                CUTDATA2=','$var
            fi
        fi
        COLCNT=$(($COLCNT + 1))
        
        # CUTDATA2=$line" | cut -f 1 -d','" 
        # echo $CUTDATA2
        # echo $line | cut -f $var -d ','
        CUTDATA=$CUTDATA$CUTDATA2
    done
    echo '1: '$CUTDATA
    # CUTDATA2='1,2,3'
    # echo $line | cut -f  ${CUTDATA2} -d ','
  fi 

  if [[ ${ROWCNT} -eq 3 ]]; then
    COLCNT=0
    CUTDATA=''
    CUTDATA2=''
    for var in {2..100}
    do 
        CUTDATA2=$(echo $line | cut -f $var -d ',') 
        if [[ $CUTDATA2 ]]; then
            if [[ ${COLCNT} -eq 0 ]]; then
                CUTDATA2=$var
            else
                CUTDATA2=','$var
            fi
        fi
        COLCNT=$(($COLCNT + 1))
        
        # CUTDATA2=$line" | cut -f 1 -d','" 
        # echo $CUTDATA2
        # echo $line | cut -f $var -d ','
        CUTDATA=$CUTDATA$CUTDATA2
    done
    echo '2: '$CUTDATA
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