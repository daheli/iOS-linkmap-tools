#!/bin/bash
#echo "" > /tmp/method.txt;

# for((i=83;i<=111;i++));do    
# 	col_number=6
# 	if [ $i -ge 100 ]; then	
# 		col_number=5
# 	fi
# 	cat /Users/lidahe/Library/Developer/Xcode/DerivedData/GMLibBundle-gjhxlbmiadlhyxbmtpumgajbzvzz/Build/Intermediates/Sample.build/Release-iphoneos/Sample.build/Sample-LinkMap-normal-arm64--LinkMap--.txt | grep $i']' | grep -E '(\-|\+)\[' | grep -E -v '___|.cxx_destruct' | awk '{print $'$col_number'}'
# 	# >> /tmp/method.txt
# done;

LINK_PATH=$1
LINK_PATH2=$2
TEMP=/tmp/linkmap.txt
echo 'path='$LINK_PATH

echo -e "\n↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ OC ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓"
node ~/bin/linkmap.js $LINK_PATH -h | grep 'libGame' | grep '(GM\|Cocoa'
echo -e "\n↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ C++ ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓"
node ~/bin/linkmap.js $LINK_PATH -h | grep 'libGame' | grep -v '(GM\|Cocoa'

SIZE_1=`node ~/bin/linkmap.js $LINK_PATH | grep 'libGame' | grep '(GM\|Cocoa' | awk '{sum+=$2};END {print sum}'`
SIZE_2=`node ~/bin/linkmap.js $LINK_PATH | grep 'libGame' | grep -v '(GM\|Cocoa' | awk '{sum+=$2};END {print sum}'`
SIZE_0=`expr $SIZE_1 + $SIZE_2`
echo -e "\ntotle:$SIZE_0 | oc:$SIZE_1 | c++:$SIZE_2"
