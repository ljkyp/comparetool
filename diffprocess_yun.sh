#!/bin/sh
#  - 파일리스트 작성한것을 호출
#  - 파일 컨버젼 셀호출하는 기능
#  - sort
#  - 비교된 결과 diffresult 에 만들어 넣는 기능
#  - 데이타 건수 비교 표시?
#  - new 또는 old에 파일 컨버젼 선택( 어느 한쪽만 필요한 경우, 둘다 필요한 경우)

# 신,현 파일 리스트 , 헤더

#컨버전 셀 호출
#sort 신, 현
#wc 신 ,현  
#diff 신 현 > ./diffresult/이름

#sh ./diffprocess_yun.sh ./newdata/datacsv1.csv ./olddata/datacsv1.csv 0

#파일이름 리스트를 받음?
#newdatalist=$1
#파라미터 지정
newdataname=$1
olddataname=$2
header_flg=$3
newdatapath=./newdata/
olddatapath=./olddata/
#건 수 지정후 파일
wc_new='wc_'${newdataname}
wc_old='wc_'$olddataname
#sort후 파일
newdatasort=sort_${newdataname}
olddatasort=sort_${olddataname}
#컨버전 셀 호출

#리스트로 받을경우 ?
#for 
sh ./conversionfile.ksh ${newdatapath} ${newdataname} ${header_flg}

#cp $newdatapath/$newdataname $newdatapath/$wc_new
#cp $olddatapath/$olddataname $olddatapath/$wc_old

#데이터 건 수 저장
wc ${newdatapath}/${newdataname} > ${newdatapath}/${wc_new}
wc ${olddatapath}/${olddataname} > ${olddatapath}/${wc_old}

#sort처리
newdatasort=sort_${newdataname}
olddatasort=sort_${olddataname}

cat ${newdatapath}/${newdataname} |sort > ${newdatapath}/${newdatasort}
cat ${olddatapath}/${olddataname} |sort > ${olddatapath}/${olddatasort}

#diff처리
diff -w ${newdatapath}/${newdatasort} ${olddatapath}/${olddatasort} > ./diffresult/${newdataname}
#done