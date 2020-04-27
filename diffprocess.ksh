#!/bin/ksh
#  - 파일리스트 작성한것을 호출
#  - 파일 컨버젼 셀호출하는 기능
#  - SORT
#  - 비교된 결과 diffresult 에 만들어 넣는 기능
#  - 데이타 건수 비교 표시?
#  - new 또는 old에 파일 컨버젼 선택( 어느 한쪽만 필요한 경우, 둘다 필요한 경우)

#sh ./diffprocess_yun.sh 0

# INPUT OUTPUT path

#파라미터 지정
#파일 리스트파일 지정
FILELIST='./pattern/filelist.csv'
HEADER_FLG=$1
SINPATH=./newdata/
GENPATH=./olddata/
SINOUTPUTPATH=./newoutput/
GENOUTPUTPATH=./oldoutput/


FILECAT=`cat ${FILELIST}`
#COUNT=0

#파라미터 체크
#if [[ $# -ne 1 ]]; then
#    echo '引数は1個必要（現：'$#'個）'
#    exit 255
#fi
for n in ${FILECAT}
do
    #FILENAME='FILENAME'
    #COUNT=$((COUNT+1))
    #FILENAME=$FILENAME$COUNT
    #echo $n
    #$n=`cut -f 1 -d "$" $n`
    FILENAME=$n
    echo $FILENAME

   #건 수 지정후 파일
   WC_NEW='WC_'${FILENAME}
   WC_OLD='WC_'${FILENAME}
   #SORT후 파일
   SINSORTDATA=SORT_${FILENAME}
   GENSORTDATA=SORT_${FILENAME}

#컨버전 셀 호출
#HEADER_FLG = 0 header なし,　HEADER_FLG = 1 header あり
#oldNewFlag = 0, oldNewFlag = 1　新行
#新
    ksh ./conversionfile.ksh ${SINPATH} ${FILENAME} ${HEADER_FLG} 1 
#現
    ksh ./conversionfile.ksh ${GENPATH} ${FILENAME} ${HEADER_FLG} 0

#데이터 건 수 저장
    wc ${SINOUTPUTPATH}${FILENAME} > ${SINOUTPUTPATH}${WC_NEW}
    wc ${GENOUTPUTPATH}${FILENAME} > ${GENOUTPUTPATH}${WC_OLD}

#SORT처리
    cat ${SINOUTPUTPATH}${FILENAME} | sort > ${SINOUTPUTPATH}${SINSORTDATA}
    cat ${GENOUTPUTPATH}${FILENAME} | sort > ${GENOUTPUTPATH}${GENSORTDATA}
    #| SORT
#diff처리
    diff -wq ${SINOUTPUTPATH}${SINSORTDATA} ${GENOUTPUTPATH}${GENSORTDATA} > ./diffresult/diff_${FILENAME}
echo "end"
    cat ./diffresult/diff_${FILENAME}
done
