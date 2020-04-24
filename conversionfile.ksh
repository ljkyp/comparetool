#!/bin/ksh

# 実行コマンド 例）
# ksh ./conversionfile.ksh ./newdata/ datacsv1.csv 0 1

# 引数確認
###todo### 引数追加される予定
if [[ $# -ne 4 ]]; then
    echo '引数は4個必要（現：'$#'個）'
    exit 255
fi

inputDataPath=$1
inputDataFile=$2
headerFlag=$3
oldNewFlag=$4

if [[ oldNewFlag -eq 0 ]]; then
    outputDataPath='./oldoutput/'
elif [[ oldNewFlag -eq 1 ]]; then
    outputDataPath='./newoutput/'
else
    echo '現新Flagは０または１）'
    exit 255
fi

inputFileName=${inputDataFile%.*}
inputFileExt=${inputDataFile#*.}

outputDataFile=$outputDataPath$inputDataFile
patternPath='./pattern/'
patternFile=$patternPath$inputFileName'.csv'

if [[ $headerFlag -eq 1 ]]; then
    tail +2 $inputDataPath$inputDataFile > ./tempInputData.csv
elif [[ $headerFlag -eq 0 ]]; then
    cat $inputDataPath$inputDataFile > ./tempInputData.csv
else
    echo 'headerFlagは０または１）'
    exit 255
fi

# パターンファイルから比較対象を抽出する。
###todo### ファイル名を変数化する予定
tail -n 1 $patternFile |sed 's/\([^,]*\),\(.*\)/\2/' > ./tempPattern.csv

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

# 拡張子確認
if [[ $inputFileExt == 'csv' ]]; then
    # 拡張子がcsvの場合

    # awk用パターンファイルから指定された項目を出力する。
    pattern=$(<./tempPattern3.csv)

    awk 'BEGIN{ FS=","; OFS=","; } { print '$pattern'; }' ./tempInputData.csv > $outputDataFile

elif [[ $inputFileExt == 'txt' ]]; then
    # 拡張子がtxtの場合

    length=$(awk 'BEGIN{ FS=","; OFS=","; } { if(NR == 3){ print $0 } }' $patternFile |sed 's/\([^,]*\),\(.*\)/\2/')

    lengthArr=( )

    count=0
    isRemained=TRUE

    while $isRemained
    do
        count=$(( $count + 1 ))
        var=$(echo $length | cut -f $count -d ',') 
        if [[ $var != '' ]]; then
            lengthArr[$count-1]=$var
        else
            isRemained=FALSE
        fi
    done

    count=0
    isRemained=TRUE

    touch ./tempTextPattern.csv

    while read line
    do
        while $isRemained
        do
            if [[ ${#lengthArr[@]} -ne $count ]]; then
                if [[ $count -eq 0 ]]; then
                    div1=$(echo $line | cut -c 1-${lengthArr[$count]}) 
                    div2=$(echo $line | sed 's/\(^'$div1'\)\(.*\)/\2/') 
                else
                    div2=$(echo $result | cut -d ',' -f $(expr $count + 1))
                    div1=$div1,$(echo $div2 | cut -c 1-${lengthArr[$count]})
                    div2=$(echo $div2 | cut -c $(expr ${lengthArr[$count]} + 1)-)
                fi

                result=$div1","$div2
            else
                echo $result |sed 's/\(\,$\)//g' >> ./tempTextPattern.csv
                isRemained=FALSE
            fi

            count=$(( $count + 1 ))
        done
        count=0
        isRemained=TRUE
    done < ./tempInputData.csv

    # awk用パターンファイルから指定された項目を出力する。
    pattern=$(<./tempPattern3.csv)

    awk 'BEGIN{ FS=","; OFS=""; } { print '$pattern'; }' ./tempTextPattern.csv > $outputDataFile

else
    # 拡張子が正しくない場合
    echo '拡張子がtxtやcsvではない。'
    exit 255
fi

# ゴミデータ削除
if [[ -f "./tempPattern.csv" ]]; then
    rm ./tempPattern.csv
fi
if [[ -f "./tempPattern2.csv" ]]; then
    rm ./tempPattern2.csv
fi
if [[ -f "./tempPattern3.csv" ]]; then
    rm ./tempPattern3.csv
fi
if [[ -f "./tempInputData.csv" ]]; then
    rm ./tempInputData.csv
fi
if [[ -f "./tempTextPattern.csv" ]]; then
    rm ./tempTextPattern.csv
fi

# 正常終了
exit 0
