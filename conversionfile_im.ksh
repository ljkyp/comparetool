#!/bin/ksh
#sh ./test.sh ./newdata/ datatxt11.txt 0 1
#sh ./test.sh ./newdata/ datacsv11.csv 0 1

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
TEMP_PATTERN='./tempPattern.csv'
TEMP_PATTERN2='./tempPattern2.csv'
TEMP_PATTERN3='./tempPattern3.csv'
TEMP_LENGTH='./lengthPattern.csv'
TEMP_LENGTH2='./lengthPattern2.csv'
TEMP_LENGTH3='./lengthPattern3.csv'
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
# パターンファイルから項目Lengthを抽出する。
tail -n 2 $PATTERN_FILE |sed 's/\([^,]*\),\(.*\)/\2/' | sed '2d' > $TEMP_LENGTH


COUNT=0
IS_REMAINED=TRUE
START=1
END=0

touch $TEMP_PATTERN2
touch $TEMP_LENGTH2

# awk用パターンファイルを作成する。
while [ $IS_REMAINED == TRUE ]
do
    COUNT=$(( $COUNT + 1 ))
    RESULT=`cat $TEMP_PATTERN | cut -f $COUNT -d ','`
    if [[ $RESULT != '' ]]; then
        #特殊文字排除
        RESULT=`echo $RESULT | sed 's/[^0-9]//g'`

        if [[ $RESULT != '0' ]]; then
            echo -n '$'$COUNT',' >> $TEMP_PATTERN2
        fi
    else
        #最後の','を抜かして出力'
        sed 's/\(\,$\)//g' $TEMP_PATTERN2 > $TEMP_PATTERN3
        IS_REMAINED=FALSE
    fi

    #cut用　length計算
    RESULT2=`cat $TEMP_LENGTH | cut -f $COUNT -d ','`
    if [[ $RESULT != '' ]]; then
        #特殊文字排除
        RESULT2=`echo $RESULT2 | sed 's/[^0-9]//g'`
        #cutするEnd位置計算
        if [[ $END -eq 0 ]]; then
            END=$RESULT2
        else
            END=`expr $END + $RESULT2`
        fi

        if [[ $RESULT != '0' ]]; then
            echo -n  $START'-'$END',' >> $TEMP_LENGTH2
        fi
        #cutするStart位置計算
        START=`expr $END + 1`

    else
        #最後の','を抜かして出力'
        sed 's/\(\,$\)//g' $TEMP_LENGTH2 > $TEMP_LENGTH3
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

    # awk用パターンファイルから指定された項目を出力する。
    PATTERN=$(<$TEMP_LENGTH3)

    # 入力データを変換し、出力ファイルを作成する。
    # cat ./newdata/datatxt1.txt | cut -c1-1,2-5,6-10,11-14,23-26,27-30,31-34,35-38
    cat $TEMP_INPUT_DATA | cut -c$PATTERN > $OUTPUT_DATA_FILE

else
    # 拡張子が正しくない場合
    echo '拡張子がtxtやcsvではない。'
    exit 255
fi

#原本ファイル
# cat  $TEMP_INPUT_DATA
# echo ''
#変換後ファイル
# cat $OUTPUT_DATA_FILE


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

if [[ -f "$TEMP_LENGTH2" ]]; then
    rm $TEMP_LENGTH2
fi
if [[ -f "$TEMP_LENGTH22" ]]; then
    rm $TEMP_LENGTH22
fi
if [[ -f "$TEMP_LENGTH23" ]]; then
    rm $TEMP_LENGTH23
fi

# 正常終了
exit 0
