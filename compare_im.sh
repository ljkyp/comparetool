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
ROWCNT=0 
COLCNT=0 

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

while read line 
do
  ROWCNT=$(($ROWCNT + 1))
  if [[ ${ROWCNT} -eq 3 ]]; then
    for var in {1..3}
    do 
        CUTDATA2=$var
        CUTDATA2="echo $line | cut -f $var -d ','" 
        $CUTDATA2
        echo $line | cut -f $var -d ','
        # CUTDATA=$CUTDATA$CUTDATA2
    done
  fi 
done < ${IN_FILE}

# echo ${CUTDATA}


# while read line 
# do
#   ROWCNT=$(($ROWCNT + 1))
#   if [[ ${ROWCNT} -eq 3 ]]; then
# 	echo ${line} | cut -f 1-3 -d ',' 
# 	echo ${line} | awk '{print $1}'
#   fi 
# done < ${IN_FILE}