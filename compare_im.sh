#!/bin/sh

#入力ファイル（現または新）のフルパス
IN_FILE=$1
#出力ファイルのフルパス
OUT_FILE=$2
#ヘッダ有無
#HEAD_FLAG=$3
#外部定義(①ファイルレイアウトのパラメータファイル)
#FILE_LAYOUT=$4
#外部定義(②ソートキー)
#SORT_FLAG=$5
#外部定義(③除外する項目のパラメータファイル)
#NOJOKI_ITEM=$6
#Pattern file 条件チェック
#LINECNT=0

if [[ (echo ${IN_FILE} | grep -i '.csv') ]]; then
    echo "OK"
fi

# while read line 
# do
#   LINECNT=$(($LINECNT + 1))
#   #echo 'cnt = ' + ${count}
#   if [[ ${LINECNT} -eq 3 ]]; then
# 	echo ${line} | cut -f 1-3 -d ',' 
# 	echo ${line} | awk '{print $1}'
#   fi 
# done < ${IN_FILE}



#cut -f 1,3,4 -d ',' aaa.txt > test1

#cat aaa.txt | awk '{print $1 $2}' | sort

#cut -c1-3,4-5,6-10  bbb.csv


# pattern 생략.
# awk '{ print }' ./file.txt      # file.txt의 모든 레코드 출력.

# action 생략.
# awk '/p/' ./file.txt            # file.txt에서 p를 포함하는 레코드 출력.
