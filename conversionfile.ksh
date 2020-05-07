#!/bin/ksh
#ksh ./conversionfile.ksh ./newdata/ datatxt11.txt 0 1     #header なし ソートキー なし
#ksh ./conversionfile.ksh ./newdata/ datatxt11.txt 1 1     #header あり ソートキー なし
#ksh ./conversionfile.ksh ./newdata/ datatxt11.txt 1 1 2,4 #header あり ソートキー あり
#ksh ./conversionfile.ksh ./newdata/ datacsv11.csv 0 1

if [[ $# -ne 4 && $# -ne 5 ]]; then
    echo '引数は4個または5個必要（現：'$#'個）'
    exit 255
fi

# 入力データパス
INPUT_DATA_PATH=$1
# 入力データファイル名
INPUT_DATA_FILE=$2
# ヘッダーフラグ
HEADER_FLAG=$3
# 現新フラグ
OLD_NEW_FLAG=$4
# ソートキー
SORT_KEY=$5


# 現新フラグによって出力データのパスを設定
if [ $OLD_NEW_FLAG -eq 0 ]; then
    OUTPUT_DATA_PATH = './oldoutput/'
elif [ $OLD_NEW_FLAG -eq 1 ]; then
    OUTPUT_DATA_PATH="./newoutput/"
else
    echo '現新Flagは０または１'
    exit 255
fi


# 入力ファイル名（拡張子抜き）
INPUT_FILE_NAME=${INPUT_DATA_FILE%.*}
# 入力ファイルの拡張子（ファイル名抜き）
INPUT_FILE_EXT=${INPUT_DATA_FILE#*.}

# 出力ファイルフルパス
OUTPUT_DATA_FILE=$OUTPUT_DATA_PATH$INPUT_DATA_FILE
# パターンファイルパス
PATTERN_PATH='./pattern/'
# パターンファイル名
PATTERN_FILE=$PATTERN_PATH$INPUT_FILE_NAME'.csv'

# 仮ファイル
TEMP_INPUT_DATA='./tempInputData.csv'
TEMP_LENGTHPATTERN='./lengthPattern.csv'
TEMP_OUTPUTPATTERN='./outputpattern.csv'
TEMP_OUTPUTPATTERN2='./outputpattern2.csv'
TEMP_OUTPUTPATTERN3='./outputpattern3.csv'

# ヘッダーフラグによるヘッダー削除処理
if [[ $HEADER_FLAG -eq 1 ]]; then
    tail -n +2 $INPUT_DATA_PATH$INPUT_DATA_FILE > $TEMP_INPUT_DATA
elif [[ $HEADER_FLAG -eq 0 ]]; then
    cat $INPUT_DATA_PATH$INPUT_DATA_FILE > $TEMP_INPUT_DATA
else
    echo 'HEADER_FLAGは０または１）'
    exit 255
fi


# csvファイルは4番目の行の値を利用する
tail -n 1 $PATTERN_FILE |sed 's/\([^,]*\),\(.*\)/\2/' > $TEMP_OUTPUTPATTERN
# txtファイルは3番目の行の値を利用する
tail -n 2 $PATTERN_FILE |sed 's/\([^,]*\),\(.*\)/\2/' | sed '2d' > $TEMP_LENGTHPATTERN



COUNT=0
IS_REMAINED=TRUE
START=1
END=0

touch $TEMP_OUTPUTPATTERN2

if [[ $INPUT_FILE_EXT == 'csv' || $INPUT_FILE_EXT == 'CSV' ]]; then
    # CSVファイルのawk用パターンファイルを作成する。
    while [ $IS_REMAINED == TRUE ]
    do
        COUNT=$(( $COUNT + 1 ))
        #patternファイルでTXTは出力制限項目を、CSVは項目長さを読んで値があれば
        OUTPUT_ITEM=`cat $TEMP_OUTPUTPATTERN | cut -f $COUNT -d ','`
        if [[ $OUTPUT_ITEM != '' ]]; then
            #特殊文字排除
            OUTPUT_ITEM=`echo $OUTPUT_ITEM | sed 's/[^0-9]//g'`
            #Patternによって'0'は出力制限
            if [[ $OUTPUT_ITEM != '0' ]]; then
                echo -n '$'$COUNT',' >> $TEMP_OUTPUTPATTERN2
            fi
        else
            IS_REMAINED=FALSE
        fi
    done
elif [[ $INPUT_FILE_EXT == 'txt' || $INPUT_FILE_EXT == 'TXT' ]]; then
    # TXTファイルのsut用パターンファイルを作成する。
    while [ $IS_REMAINED == TRUE ]
    do
        COUNT=$(( $COUNT + 1 ))
        #patternファイルでTXTは出力制限項目を、CSVは項目長さを読んで値があれば
        OUTPUT_ITEM=`cat $TEMP_OUTPUTPATTERN | cut -f $COUNT -d ','`
        #cut用　length計算
        CUT_LENGTH=`cat $TEMP_LENGTHPATTERN | cut -f $COUNT -d ','`
        #patternファイルの出力制限項目を読んで値があれば
        if [[ $OUTPUT_ITEM != '' ]]; then
            #特殊文字排除
            CUT_LENGTH=`echo $CUT_LENGTH | sed 's/[^0-9]//g'`
            #cutするEnd位置計算
            if [[ $END -eq 0 ]]; then
                END=$CUT_LENGTH
            else
                END=`expr $END + $CUT_LENGTH`
            fi
            #Patternによって'0'は出力制限
            if [[ $OUTPUT_ITEM != '0' ]]; then
                echo -n  $START'-'$END',' >> $TEMP_OUTPUTPATTERN2
            fi
            #cutするStart位置計算
            START=`expr $END + 1`

        else
            IS_REMAINED=FALSE
        fi
    done
fi

#最後の','を抜かして出力'
sed 's/\(\,$\)//g' $TEMP_OUTPUTPATTERN2 > $TEMP_OUTPUTPATTERN3
# パターンファイルから指定された項目を出力する。
PATTERN=$(<$TEMP_OUTPUTPATTERN3)

if [[ -n $SORT_KEY ]]; then
    SORT_PATTERN=`echo $SORT_KEY |awk 'BEGIN{ FS=","; } { for (i=1; i<=NF; i++) printf "-k "$i","$i" "; }'`
fi

# 拡張子確認
if [[ $INPUT_FILE_EXT == 'csv' || $INPUT_FILE_EXT == 'CSV' ]]; then

    if [[ -z $SORT_PATTERN ]]; then
        # 入力データを変換し、出力ファイルを作成する。
        awk 'BEGIN{ FS=","; OFS=","; } { print '$PATTERN'; }' $TEMP_INPUT_DATA > $OUTPUT_DATA_FILE
    else
        # 入力データを変換し、出力ファイルを作成する。
        sort $SORT_PATTERN -t ',' $TEMP_INPUT_DATA | awk 'BEGIN{ FS=","; OFS=","; } { print '$PATTERN'; }' > $OUTPUT_DATA_FILE
    fi

elif [[ $INPUT_FILE_EXT == 'txt' || $INPUT_FILE_EXT == 'TXT' ]]; then

    if [[ -z $SORT_PATTERN ]]; then
        # 入力データを変換し、出力ファイルを作成する。
        # cat ./newdata/datatxt1.txt | cut -c1-1,2-5,6-10,11-14,23-26,27-30,31-34,35-38
        cat $TEMP_INPUT_DATA | cut -c$PATTERN > $OUTPUT_DATA_FILE
    else
        # 入力データを変換し、出力ファイルを作成する。
        #cat $TEMP_INPUT_DATA | cut -c$PATTERN --output-delimiter=' ' | sort $SORT_PATTERN -t ' ' > $OUTPUT_DATA_FILE
        cat $TEMP_INPUT_DATA | cut -c$PATTERN --output-delimiter=' ' | sort $SORT_PATTERN -t ' ' > $OUTPUT_DATA_FILE
    fi

else
    # 拡張子が正しくない場合
    echo '拡張子がtxtやcsvではない。'
    exit 255
fi

#原本ファイル
#echo '原本ファイル'
#cat  $INPUT_DATA_PATH$INPUT_DATA_FILE
#echo ''
#変換後ファイル
#echo '変換後ファイル'
#cat $OUTPUT_DATA_FILE


# 仮ファイル削除(出力パータンファイル)
if [[ -f "$TEMP_LENGTHPATTERN" ]]; then
    rm $TEMP_LENGTHPATTERN
fi
if [[ -f "$TEMP_OUTPUTPATTERN" ]]; then
    rm $TEMP_OUTPUTPATTERN
fi
if [[ -f "$TEMP_OUTPUTPATTERN2" ]]; then
    rm $TEMP_OUTPUTPATTERN2
fi
if [[ -f "$TEMP_OUTPUTPATTERN3" ]]; then
    rm $TEMP_OUTPUTPATTERN3
fi
if [[ -f "$TEMP_INPUT_DATA" ]]; then
    rm $TEMP_INPUT_DATA
fi

# 正常終了
exit 0