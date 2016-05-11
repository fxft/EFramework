#!/bin/sh

#  commit.sh
#  EFWKLib
#
#  Created by mac on 15/11/6.
#  Copyright © 2015年 mac. All rights reserved.


echo "${CONFIGURATION_BUILD_DIR}"
echo "${CONFIGURATION_BUILD_DIR}/../"
echo "${SRCROOT}"

#rm -rf "${SRCROOT}/Frameworks"

mkdir -p "${SRCROOT}/Frameworks/Public"
mkdir -p "${SRCROOT}/Frameworks/PublicOS"

# 从系统编译目录复制到工程目录
cp -r -f ${CONFIGURATION_BUILD_DIR}/../*  ${SRCROOT}/Frameworks/

# 复制一份初始化到Public
#cp -r -f ${SRCROOT}/Frameworks/Debug-iphoneos/*  ${SRCROOT}/Frameworks/Public/
#cp -r -f ${SRCROOT}/Frameworks/Release-iphoneos/*  ${SRCROOT}/Frameworks/PublicOS/


# 输入、输出路径
iphoneos=${SRCROOT}/Frameworks/Debug-iphoneos

iphonesimulator=${SRCROOT}/Frameworks/Debug-iphonesimulator

outputpath=${SRCROOT}/Frameworks/Public

# 地址
filelist=`find ${iphoneos} -name *.framework`
for file in $filelist
do
# 文件
 filename=${file##*/}
# 文件名
name=${filename%.*}

#iospath=${iphoneos}/${name}.framework/${name}
#isimpath=${iphonesimulator}/${name}.framework/${name}
#
#opath=${outputpath}/${name}.framework/${name}

iospath=${file}/${name}
isimpath=${file/Debug-iphoneos/Debug-iphonesimulator}/${name}

opath=${outputpath}/${name}.framework/${name}

#先拷贝一个副本到通用版本Public
cp -r -f ${file}  ${SRCROOT}/Frameworks/Public/

#先拷贝一个副本到发布版本PublicOS

cp -r -f ${file/Debug-iphoneos/Release-iphoneos}  ${SRCROOT}/Frameworks/PublicOS/

lipo -create ${iospath} ${isimpath} -output ${opath}

echo "lipo -create ${iospath}     ${isimpath}    -output ${opath}"


done

mkdir -p "${SRCROOT}/../../../comm/EF/Frameworks/Public"
mkdir -p "${SRCROOT}/../../../comm/EF/Frameworks/PublicOS"

cp -r -f ${SRCROOT}/Frameworks/Public/*  ${SRCROOT}/../../../comm/EF/Frameworks/Public/
cp -r -f ${SRCROOT}/Frameworks/PublicOS/*  ${SRCROOT}/../../../comm/EF/Frameworks/PublicOS/

#lipo -create ${SRCROOT}/Frameworks/Debug-iphoneos/EFMWK.framework/EFMWK ./Debug-iphonesimulator/EFMWK.framework/EFMWK -output EFMWK.framework/EFMWK

