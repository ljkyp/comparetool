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
sin_name=$1
gen_name=$2
header_flg=$3
sin_path=./newdata/
gen_path=./olddata/
sinoutputpath=./newoutput/
genoutputpath=./oldoutput/
#건 수 지정후 파일
wc_new='wc_'${sin_name}
wc_old='wc_'${gen_name}
#sort후 파일
sin_sortdata=sort_${sin_name}
gen_sortdata=sort_${gen_name}

#파라미터 체크
if [[ $# -ne 3 ]]; then
    echo '引数は3個必要（現：'$#'個）'
    exit 255
fi

#컨버전 셀 호출
#header_flg = 0 header なし,　header_flg = 1 header あり
#oldNewFlag = 0, oldNewFlag = 1　新行
#新
ksh ./conversionfile.ksh ${sin_path} ${sin_name} ${header_flg} 1 
#現
ksh ./conversionfile.ksh ${gen_path} ${gen_name} ${header_flg} 0

#데이터 건 수 저장
wc ${sinoutputpath}/${sin_name} > ${sinoutputpath}/${wc_new}
wc ${genoutputpath}/${gen_name} > ${genoutputpath}/${wc_old}

#sort처리
cat ${sinoutputpath}/${sin_name} |sort > ${sinoutputpath}/${sin_sortdata}
cat ${genoutputpath}/${gen_name} |sort > ${genoutputpath}/${gen_sortdata}

#diff처리
diff -w ${sinoutputpath}/${sin_sortdata} ${genoutputpath}/${gen_sortdata} > ./diffresult/diff_${sin_name}
#done