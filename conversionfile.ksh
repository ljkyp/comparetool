#!/bin/ksh

# 引数確認
###todo### 引数追加される予定
if [[ $# -ne 3 ]]; then
    echo '引数は3個必要（現：'$#'個）'
    exit 255
fi

inputDataPath=$1
inputDataFile=$2
headerFlag=$3

#outputDataPath='./output/'
outputDataFile='./output/'$inputDataFile
#patternPath='./pattern/'
patternFile='./pattern/'$inputDataFile

inputFileExt=${inputDataFile#*.}

# 現新の拡張子比較
if [[ $inputFileExt != $oldFileExt ]]; then
   echo '比較対象の拡張子が異なる。'
   exit 255
fi

if [[ $headerFlag -eq 1 ]]; then
    headDeletedFile=$(tail +2 $inputDataFile)
    cat headDeletedFile > $inputDataFile
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
    awk 'BEGIN{ FS=","; OFS=","; } { print '$pattern'; }' $inputDataFile
    # 失敗コード : awk -v ptn=$pattern 'BEGIN{ FS=","; OFS=","; } { print ptn; }' $inputDataFile

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
    done < $2

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

# 正常終了
exit 0
