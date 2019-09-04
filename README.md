## 简介

FAAD2是一个开源的MPEG-4和MPEG-2 AAC解码器，它是根据GPLV2许可证授权的。

官网地址：https://www.audiocoding.com/faad2.html

FAAD2具有如下特点：

- 可移植性
- 快速
- LC, Main, LTP, SBR, PS 支持
- DRM support through DreaM
- DAB+ 支持

## 如何使用

### libfaad库的编译

- 下载faad2-2.7.tar.bz2并解压。
- 执行build脚本，编译并安装到当前目录output文件夹下。build脚本如下：

```c
#!/bin/sh                                                                                                                                                                     
CROSS_COMPILE=
ARCH=

TARGET_DIR=$(cd `dirname $0`; pwd)/output
CURRENT_DIR=$(cd `dirname $0`; pwd)

build_faad2() {
    cd faad2-2.7
    ./configure prefix=$TARGET_DIR \
        CFLAGS="-g -O0 -DFIXED_POINT" \
        CC=$CROSS_COMPILE\gcc \
        STRIP=$CROSS_COMPILE\strip \
        RANLIB=$CROSS_COMPILE\ranlib \
        OBJDUMP=$CROSS_COMPILE\objdump \
        NM=$CROSS_COMPILE\nm \
        AR=$CROSS_COMPILE\ar \
        AS=$CROSS_COMPILE\as ;

    make ; make install || exit 1
    cd -
}

build_faad2
```

- 编译出的结果如下：

```c
yingc@yingc:~/thirdparty/faad/output$ tree
.
├── bin
│   └── faad
├── include
│   ├── faad.h
│   ├── mp4ff.h
│   ├── mp4ffint.h
│   └── neaacdec.h
├── lib
│   ├── libfaad.a
│   ├── libfaad.la
│   ├── libfaad.so -> libfaad.so.2.0.0
│   ├── libfaad.so.2 -> libfaad.so.2.0.0
│   ├── libfaad.so.2.0.0
│   └── libmp4ff.a
└── share
    └── man
        └── manm
            └── faad.man

6 directories, 12 files
yingc@yingc:~/thirdparty/faad/output$ 

```

### m4a文件解码示例

- output/bin目录下有个faad自带的测试文件，现在解码一个m4a文件生成wav文件，如下所示：

```c
yingc@yingc:~/thirdparty/faad/output/bin$ ls
faad  test_s2.m4a
yingc@yingc:~/thirdparty/faad/output/bin$ ./faad test_s2.m4a -o test_s2.wav
 *********** Ahead Software MPEG-4 AAC Decoder V2.7 ******************

 Build: Jul 18 2019
 Copyright 2002-2004: Ahead Software AG
 http://www.audiocoding.com
 Fixed point version

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License.

 **************************************************************************

test_s2.m4a file info:

HE AAC  39.965 secs, 2 ch, 44100 Hz

tool: Lavf56.40.101

  ---------------------
 | Config:  2 Ch       |
  ---------------------
 | Ch |    Position    |
  ---------------------
 | 00 | Left front     |
 | 01 | Right front    |
  ---------------------

Decoding test_s2.m4a took:  0.80 sec. 49.88x real-time.

```

- 采用ffprobe查看是否解码成功或直接用vlc等播放器播放test_s2.wav文件。如下所示：

```c
yingc@yingc:~/thirdparty/faad/output/bin$ ffprobe test_s2.wav 
ffprobe version 3.4.6-0ubuntu0.18.04.1 Copyright (c) 2007-2019 the FFmpeg developers
  built with gcc 7 (Ubuntu 7.3.0-16ubuntu3)
  configuration: --prefix=/usr --extra-version=0ubuntu0.18.04.1 --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --enable-gpl --disable-stripping --enable-avresample --enable-avisynth --enable-gnutls --enable-ladspa --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libflite --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libmp3lame --enable-libmysofa --enable-libopenjpeg --enable-libopenmpt --enable-libopus --enable-libpulse --enable-librubberband --enable-librsvg --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libx265 --enable-libxml2 --enable-libxvid --enable-libzmq --enable-libzvbi --enable-omx --enable-openal --enable-opengl --enable-sdl2 --enable-libdc1394 --enable-libdrm --enable-libiec61883 --enable-chromaprint --enable-frei0r --enable-libopencv --enable-libx264 --enable-shared
  libavutil      55. 78.100 / 55. 78.100
  libavcodec     57.107.100 / 57.107.100
  libavformat    57. 83.100 / 57. 83.100
  libavdevice    57. 10.100 / 57. 10.100
  libavfilter     6.107.100 /  6.107.100
  libavresample   3.  7.  0 /  3.  7.  0
  libswscale      4.  8.100 /  4.  8.100
  libswresample   2.  9.100 /  2.  9.100
  libpostproc    54.  7.100 / 54.  7.100
Input #0, wav, from 'test_s2.wav':
  Duration: 00:00:39.94, bitrate: 1411 kb/s
    Stream #0:0: Audio: pcm_s16le ([1][0][0][0] / 0x0001), 44100 Hz, 2 channels, s16, 1411 kb/s
yingc@yingc:~/thirdparty/faad/output/bin$ 
 
```

