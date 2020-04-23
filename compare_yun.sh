#!/bin/sh
#입력값 1신 2현 3패턴 4헤더
SIN_FILE = $1
GEN_FILE = $2
PATTERN_FILE = $3
HEADER_FLG = $4
SIN_PATH="~/Desktop/ex/comparetool/newdata"
GEN_PATH="~/Desktop/ex/comparetool/olddata"
if [ HEADER_FLG -eq 0 ]; then
	echo not header file
elif [ HEADER_FLG -eq 1 ]
	notheader_new = sed '1d'
	notheader_old = sed '1d'
fi

#cat datacsv1.csv | awk -F ',' '{print $4=""; print $0}' > newdatacsv1.csv
#awk한 파일을 sort
#sort파일을 diff 커맨드로 비교 , 비교파일을 출력 