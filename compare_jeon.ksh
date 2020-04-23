#!/bin/ksh

# 入力コマンド
# ksh ./compare_jeon.ksh 新データファイル名 現データファイル名 パターンファイル

# 引数確認
###todo### 引数追加される予定
if [[ $# -ne 3 ]]; then
    echo '引数は3個必要（現：'$#'個）'
    exit 255
fi

newDataFile=$1
oldDataFile=$2
patternFile=$3

newBaseName=$(basename $newDataFile)
newFileName=${newBaseName%.*}
newFileExt=${newBaseName#*.}

oldBaseName=$(basename $oldDataFile)
oldFileName=${oldBaseName%.*}
oldFileExt=${oldBaseName#*.}

# 現新の拡張子比較
if [[ $newFileExt != $oldFileExt ]]; then
   echo '比較対象の拡張子が異なる。'
   exit 255
fi

# 拡張子確認
if [[ $newFileExt == 'csv' ]]; then
    ###todo### 拡張子によって処理を分ける。あとで修正予定
    echo 'csv'
elif [[ $newFileExt == 'txt' ]]; then
    echo 'txt'
else
    echo '拡張子がtxtやcsvではない。'
    exit 255
fi

# 失敗コード : tail -n 1 $patternFile |sed '/^.*\{-}\,/d' 
# 失敗コード : tail -n 1 $patternFile |sed 's/^.*?\,//g'
# 失敗コード : awk 'BEGIN{ FS=","; OFS=","; } { if(NR == 4){ print $0 } }' $patternFile |sed '/^.*\,/d'
# 失敗コード : awk 'BEGIN{ FS=","; } { if(NR == 4){ for(i=2;i<=NF;i++) { print $i } } }' $patternFile

# パターンファイルから比較対象を抽出する。
###todo### ファイル名を変数化する予定
tail -n 1 $patternFile |sed 's/\([^,]*\),\(.*\)/\2/' > ./tempPattern.csv
# これも出来るコード : tail -n 1 $patternFile |awk '{sub(/[^,]*/,"");sub(/,/,"")} 1' > ./tempPattern.csv

count=0
isRemained=TRUE

touch ./tempPattern2.csv

# awk用パターンファイルを作成する。
while $isRemained
do
    count=$(( $count + 1 ))
    result=`cat ./tempPattern.csv | cut -f $count -d ','`
    if [[ $result != '' ]]; then
        if [[ $result != '0' ]]; then
            echo -n '$'$count',' >> ./tempPattern2.csv
        fi
    else
        sed 's/\(\,$\)//g' ./tempPattern2.csv > ./tempPattern3.csv
        isRemained=FALSE
    fi
done

# awk用パターンファイルから指定された項目を出力する。
pattern=$(<./tempPattern3.csv)
awk 'BEGIN{ FS=","; OFS=","; } { print '$pattern'; }' $newDataFile
# 失敗コード : awk -v ptn=$pattern 'BEGIN{ FS=","; OFS=","; } { print ptn; }' $newDataFile

# ゴミデータ削除
rm ./tempPattern.csv ./tempPattern2.csv ./tempPattern3.csv

# 正常終了
exit 0
