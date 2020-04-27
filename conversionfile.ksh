#!/bin/ksh

# 実行コマンド 例）
# ksh ./conversionfile.ksh ./newdata/ datacsv1.csv 0 1

# 引数確認
if [[ $# -ne 4 ]]; then
    echo '引数は4個必要（現：'$#'個）'
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

# 現新フラグによって出力データのパスを設定
if [[ OLD_NEW_FLAG -eq 0 ]]; then
    OUTPUT_DATA_PATH='./oldoutput/'
elif [[ OLD_NEW_FLAG -eq 1 ]]; then
    OUTPUT_DATA_PATH='./newoutput/'
else
    echo '現新Flagは０または１）'
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
TEMP_PATTERN='./tempPattern.csv'
TEMP_PATTERN2='./tempPattern2.csv'
TEMP_PATTERN3='./tempPattern3.csv'
TEMP_TEXT_PATTERN='./tempTextPattern.csv'

# ヘッダーフラグによるヘッダー削除処理
if [[ $HEADER_FLAG -eq 1 ]]; then
    tail +2 $INPUT_DATA_PATH$INPUT_DATA_FILE > $TEMP_INPUT_DATA
elif [[ $HEADER_FLAG -eq 0 ]]; then
    cat $INPUT_DATA_PATH$INPUT_DATA_FILE > $TEMP_INPUT_DATA
else
    echo 'HEADER_FLAGは０または１）'
    exit 255
fi

# パターンファイルから比較対象を抽出する。
tail -n 1 $PATTERN_FILE |sed 's/\([^,]*\),\(.*\)/\2/' > $TEMP_PATTERN

COUNT=0
IS_REMAINED=TRUE

touch $TEMP_PATTERN2

# awk用パターンファイルを作成する。
while [ $IS_REMAINED == TRUE ]
do
    COUNT=$(( $COUNT + 1 ))
    RESULT=`cat $TEMP_PATTERN | cut -f $COUNT -d ','`
    if [[ $RESULT != '' ]]; then
        if [[ $RESULT != '0' ]]; then
            echo -n '$'$COUNT',' >> $TEMP_PATTERN2
        fi
    else
        sed 's/\(\,$\)//g' $TEMP_PATTERN2 > $TEMP_PATTERN3
        IS_REMAINED=FALSE
    fi
done

# 拡張子確認
if [[ $INPUT_FILE_EXT == 'csv' ]]; then
    # 拡張子がcsvの場合

    # awk用パターンファイルから指定された項目を出力する。
    PATTERN=$(<$TEMP_PATTERN3)

    # 入力データを変換し、出力ファイルを作成する。
    awk 'BEGIN{ FS=","; OFS=","; } { print '$PATTERN'; }' $TEMP_INPUT_DATA > $OUTPUT_DATA_FILE

elif [[ $INPUT_FILE_EXT == 'txt' ]]; then
    # 拡張子がtxtの場合

    # パターンファイルから固定長ファイルの長さを取得する。
    LENGTH=$(awk 'BEGIN{ FS=","; OFS=","; } { if(NR == 3){ print $0 } }' $PATTERN_FILE |sed 's/\([^,]*\),\(.*\)/\2/')

    LENGTH_ARR=( )

    COUNT=0
    IS_REMAINED=TRUE

    # 長さ情報を配列に格納する。
    while [ $IS_REMAINED == TRUE ]
    do
        COUNT=$(( $COUNT + 1 ))
        VAR=$(echo $LENGTH | cut -f $COUNT -d ',') 
        if [[ $VAR != '' ]]; then
            LENGTH_ARR[$COUNT-1]=$VAR
        else
            IS_REMAINED=FALSE
        fi
    done

    COUNT=0
    IS_REMAINED=TRUE

    touch $TEMP_TEXT_PATTERN

    # awk用パターンファイルを作成する。
    while read LINE
    do
        while [ $IS_REMAINED == TRUE ]
        do
            if [[ ${#LENGTH_ARR[@]} -ne $COUNT ]]; then
                if [[ $COUNT -eq 0 ]]; then
                    DIV1=$(echo $LINE | cut -c 1-${LENGTH_ARR[$COUNT]}) 
                    DIV2=$(echo $LINE | sed 's/\(^'$DIV1'\)\(.*\)/\2/') 
                else
                    DIV2=$(echo $result | cut -d ',' -f $(expr $COUNT + 1))
                    DIV1=$DIV1,$(echo $DIV2 | cut -c 1-${LENGTH_ARR[$COUNT]})
                    DIV2=$(echo $DIV2 | cut -c $(expr ${LENGTH_ARR[$COUNT]} + 1)-)
                fi

                RESULT=$DIV1","$DIV2
            else
                echo $RESULT |sed 's/\(\,$\)//g' >> $TEMP_TEXT_PATTERN
                IS_REMAINED=FALSE
            fi

            COUNT=$(( $COUNT + 1 ))
        done
        COUNT=0
        IS_REMAINED=TRUE
    done < $TEMP_INPUT_DATA

    # awk用パターンファイルから指定された項目を出力する。
    PATTERN=$(<$TEMP_PATTERN3)

    # 入力データを変換し、出力ファイルを作成する。
    awk 'BEGIN{ FS=","; OFS=""; } { print '$PATTERN'; }' $TEMP_TEXT_PATTERN > $OUTPUT_DATA_FILE

else
    # 拡張子が正しくない場合
    echo '拡張子がtxtやcsvではない。'
    exit 255
fi

# 仮ファイル削除
if [[ -f "$TEMP_PATTERN" ]]; then
    rm $TEMP_PATTERN
fi
if [[ -f "$TEMP_PATTERN2" ]]; then
    rm $TEMP_PATTERN2
fi
if [[ -f "$TEMP_PATTERN3" ]]; then
    rm $TEMP_PATTERN3
fi
if [[ -f "$TEMP_INPUT_DATA" ]]; then
    rm $TEMP_INPUT_DATA
fi
if [[ -f "$TEMP_TEXT_PATTERN" ]]; then
    rm $TEMP_TEXT_PATTERN
fi

# 正常終了
exit 0
