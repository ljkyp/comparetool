#!/bin/ksh

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

outputDataFile=$outputDataPath$inputDataFile
patternPath='./pattern/'
patternFile=$patternPath$inputDataFile

inputFileExt=${inputDataFile#*.}

if [[ $headerFlag -eq 1 ]]; then
    tail +2 $inputDataPath$inputDataFile > ./tempInputData.csv
elif [[ oldNewFlag -eq 1 ]]; then
    cat $inputDataPath$inputDataFile > ./tempInputData.csv
else
    echo 'headerFlagは０または１）'
    exit 255
fi

# 拡張子確認
if [[ $inputFileExt == 'csv' ]]; then
    # 拡張子がcsvの場合

    # パターンファイルから比較対象を抽出する。
    ###todo### ファイル名を変数化する予定
    tail -n 1 $patternFile |sed 's/\([^,]*\),\(.*\)/\2/' > ./tempCsvPattern.csv

    count=0
    isRemained=TRUE

    touch ./tempCsvPattern2.csv

    # awk用パターンファイルを作成する。
    while $isRemained
    do
        count=$(( $count + 1 ))
        result=`cat ./tempCsvPattern.csv | cut -f $count -d ','`
        if [[ $result != '' ]]; then
            if [[ $result != '0' ]]; then
                echo -n '$'$count',' >> ./tempCsvPattern2.csv
            fi
        else
            sed 's/\(\,$\)//g' ./tempCsvPattern2.csv > ./tempCsvPattern3.csv
            isRemained=FALSE
        fi
    done

    # awk用パターンファイルから指定された項目を出力する。
    pattern=$(<./tempCsvPattern3.csv)

    cat ./tempInputData.csv
    cat ./tempInputData.csv |awk 'BEGIN{ FS=","; OFS=","; } { print '$pattern'; }' > $outputDataFile

    # ゴミデータ削除
    rm ./tempCsvPattern.csv ./tempCsvPattern2.csv ./tempCsvPattern3.csv

elif [[ $inputFileExt == 'txt' ]]; then
    # 拡張子がtxtの場合

    length=$(awk 'BEGIN{ FS=","; OFS=","; } { if(NR == 3){ print $0 } }' $patternFile |sed 's/\([^,]*\),\(.*\)/\2/')
    compare=$(awk 'BEGIN{ FS=","; OFS=","; } { if(NR == 4){ print $0 } }' $patternFile |sed 's/\([^,]*\),\(.*\)/\2/')

    lengthArr=( )
    compareArr=( )

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
    count_=0
    isRemained=TRUE

    while $isRemained
    do
        count=$(( $count + 1 ))
        var=$(echo $compare | cut -f $count -d ',') 
        if [[ $var != '' ]]; then
            if [[ $var == '0' ]]; then
                compareArr[$count_]=$count
                count_=$(( $count_ + 1 ))
            fi
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
                echo $result
                echo ""
            else
                echo $result |sed 's/\(\,$\)//g' >> ./tempTextPattern.csv
                isRemained=FALSE
            fi

            count=$(( $count + 1 ))
        done
        count=0
        isRemained=TRUE
    done < $tempInputData

    ##############################
    #### 未作成部分              ####
    #### csvコンバート作業とほぼ同じ ####
    ##############################

    rm ./tempTextPattern.csv
else
    # 拡張子が正しくない場合
    echo '拡張子がtxtやcsvではない。'
    exit 255
fi

rm ./tempInputData.csv

# 正常終了
exit 0
