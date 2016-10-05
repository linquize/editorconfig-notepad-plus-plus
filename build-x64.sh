#!/bin/sh
ROOT=`pwd`

CMAKE_DIR=cmake-3.6.2-win64-x64
CMAKE_ZIP=$CMAKE_DIR.zip
CMAKE=$ROOT/$CMAKE_DIR/bin/cmake.exe
if [ ! -f $CMAKE_ZIP ]; then
	echo "Downloading CMake ..." >&2
	curl -L https://cmake.org/files/v3.6/$CMAKE_ZIP > $CMAKE_ZIP
fi
echo "Unzipping CMake ..." >&2
unzip -o $CMAKE_ZIP

GCC_DIR=$ROOT/gcc
mkdir -p $GCC_DIR

MAKE_VER=make-3.81-20090914-mingw32-bin
MAKE_ZIP=$MAKE_VER.tar.gz
MAKE_URL=https://sourceforge.net/projects/mingw/files/MinGW/Extension/make/make-3.81-20090914-mingw32/$MAKE_ZIP/download
if [ ! -f $MAKE_ZIP ]; then
	echo "Downloading GNU Make ..." >&2
	curl -L $MAKE_URL > $MAKE_ZIP
fi
tar -C $GCC_DIR -xzf $MAKE_ZIP

GCC_VER=gcc-5.1.0-tdm64-1-core
GCC_ZIP=$GCC_VER.zip
GCC_URL=http://sourceforge.net/projects/tdm-gcc/files/TDM-GCC%205%20series/5.1.0-tdm64-1/$GCC_ZIP/download
if [ ! -f $GCC_ZIP ]; then
	echo "Downloading GCC Core ..." >&2
	curl -L $GCC_URL > $GCC_ZIP
fi
echo "Unzipping GCC Core ..." >&2
unzip -d $GCC_DIR -o $GCC_ZIP

BINUTILS_VER=binutils-2.25-tdm64-1
BINUTILS_ZIP=$BINUTILS_VER.zip
BINUTILS_URL=http://sourceforge.net/projects/tdm-gcc/files/GNU%20binutils/$BINUTILS_ZIP/download
if [ ! -f $BINUTILS_ZIP ]; then
	echo "Downloading binutils ..." >&2
	curl -L $BINUTILS_URL > $BINUTILS_ZIP
fi
echo "Unzipping binutils ..." >&2
unzip -d $GCC_DIR -o $BINUTILS_ZIP

MINGW_VER=mingw64runtime-v4-git20150618-gcc5-tdm64-1
MINGW_ZIP=$MINGW_VER.zip
MINGW_URL=http://sourceforge.net/projects/tdm-gcc/files/MinGW-w64%20runtime/GCC%205%20series/$MINGW_ZIP/download
if [ ! -f $MINGW_ZIP ]; then
	echo "Downloading MinGW ..." >&2
	curl -L $MINGW_URL > $MINGW_ZIP
fi
echo "Unzipping MinGW ..." >&2
unzip -d $GCC_DIR -o $MINGW_ZIP

GCC_CPP_VER=gcc-5.1.0-tdm64-1-c++
GCC_CPP_ZIP=$GCC_CPP_VER.zip
GCC_CPP_URL=http://sourceforge.net/projects/tdm-gcc/files/TDM-GCC%205%20series/5.1.0-tdm64-1/$GCC_CPP_ZIP/download
if [ ! -f $GCC_CPP_ZIP ]; then
	echo "Downloading GCC C++ ..." >&2
	curl -L $GCC_CPP_URL > $GCC_CPP_ZIP
fi
echo "Unzipping GCC C++ ..." >&2
unzip -d $GCC_DIR -o $GCC_CPP_ZIP

MAKE=$GCC_DIR/bin/mingw32-make.exe

PCRE_DIR=pcre-8.39
PCRE_ZIP=$PCRE_DIR.zip
PCRE_URL=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/$PCRE_ZIP
if [ ! -f $PCRE_ZIP ]; then
	echo "Downloading PCRE ..." >&2
	curl $PCRE_URL > $PCRE_ZIP
fi
echo "Unzipping PCRE ..." >&2
unzip -o $PCRE_ZIP
cd $PCRE_DIR
echo "Configuring PCRE ..." >&2
"$CMAKE" -G "MinGW Makefiles" -DCMAKE_MAKE_PROGRAM:String=$MAKE .
"$CMAKE" -G "MinGW Makefiles" -DCMAKE_MAKE_PROGRAM:String=$MAKE .
echo "Compiling PCRE ..." >&2
"$MAKE"

cd $ROOT
if [ ! -d editorconfig-core-c ]; then
	echo "Cloning editorconfig-core-c ..." >&2
	git clone https://github.com/editorconfig/editorconfig-core-c.git
fi
cd editorconfig-core-c
echo "Configuring editorconfig-core-c ..." >&2
"$CMAKE" -G "MinGW Makefiles" -DCMAKE_MAKE_PROGRAM:String=$MAKE -DPCRE_LIBRARY:String=$ROOT/$PCRE_DIR/libpcre.a -DPCRE_INCLUDE_DIR:String=$ROOT/$PCRE_DIR -DPCRE_STATIC:Boolean=true.
echo "Compiling editorconfig-core-c ..." >&2
"$MAKE"

cd $ROOT
if [ ! -d editorconfig-notepad-plus-plus ]; then
	echo "Cloning editorconfig-notepad-plus-plus ..." >&2
	git clone https://github.com/editorconfig/editorconfig-notepad-plus-plus.git
fi
cd editorconfig-notepad-plus-plus
echo "Configuring editorconfig-notepad-plus-plus ..." >&2
"$CMAKE" -G "MinGW Makefiles" -DCMAKE_MAKE_PROGRAM:String=$MAKE -DEDITORCONFIG_CORE_PREFIX:String=$ROOT/editorconfig-core-c -DPCRE_LIB_DIR:String=$ROOT/$PCRE_DIR
"$CMAKE" -G "MinGW Makefiles" -DCMAKE_MAKE_PROGRAM:String=$MAKE -DEDITORCONFIG_CORE_PREFIX:String=$ROOT/editorconfig-core-c -DPCRE_LIB_DIR:String=$ROOT/$PCRE_DIR
echo "Compiling editorconfig-notepad-plus-plus ..." >&2
"$MAKE"

cd $ROOT
echo "Copying output DLL ..." >&2
cp editorconfig-notepad-plus-plus/bin/unicode/libNppEditorConfig.dll NppEditorConfig.dll

