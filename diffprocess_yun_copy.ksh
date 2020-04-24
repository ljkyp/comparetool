#!/bin/ksh
#  - 파일리스트 작성한것을 호출
#  - 파일 컨버젼 셀호출하는 기능
#  - sort
#  - 비교된 결과 diffresult 에 만들어 넣는 기능
#  - 데이타 건수 비교 표시?
#  - new 또는 old에 파일 컨버젼 선택( 어느 한쪽만 필요한 경우, 둘다 필요한 경우)

#sh ./diffprocess_yun.sh datacsv1.csv datacsv1.csv 0

# INPUT OUTPUT path

#파라미터 지정
filelist='./pattern/fileist.csv'
#sin_name=$1
#gen_name=$2
header_flg=$1
sin_path=./newdata/
gen_path=./olddata/
sinoutputpath=./newoutput/
genoutputpath=./oldoutput/
#건 수 지정후 파일
wc_new='wc_'${filename}
wc_old='wc_'${filename}
#sort후 파일
sin_sortdata=sort_${filename}
gen_sortdata=sort_${filename}

filecat=`cat ${filelist}`
loop_cnt=0

#파라미터 체크
if [[ $# -ne 1 ]]; then
    echo '引数は3個必要（現：'$#'個）'
    exit 255
fi
for n in ${filecat}
do
    filename='filename'
    loop_cnt=$((loop_cnt+1))
    filename=$filename$loop_cnt
#컨버전 셀 호출
#header_flg = 0 header なし,　header_flg = 1 header あり
#oldNewFlag = 0, oldNewFlag = 1　新行
#新
    ksh ./conversionfile.ksh ${sin_path} ${filename} ${header_flg} 1 
#現
    ksh ./conversionfile.ksh ${gen_path} ${filename} ${header_flg} 0

#데이터 건 수 저장
    wc ${sinoutputpath}/${filename} > ${sinoutputpath}/${wc_new}
    wc ${genoutputpath}/${filename} > ${genoutputpath}/${wc_old}

#sort처리
    cat ${sinoutputpath}/${filename} |sort > ${sinoutputpath}/${sin_sortdata}
    cat ${genoutputpath}/${filename} |sort > ${genoutputpath}/${gen_sortdata}

#diff처리
    diff -w ${sinoutputpath}/${sin_sortdata} ${genoutputpath}/${gen_sortdata} > ./diffresult/diff_${sin_name}
done