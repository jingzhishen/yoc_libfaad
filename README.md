## 简介

该组件可用于平头哥YoC(RTOS)/Linux平台使用用以支持aac编解码功能。

FAAD2是一个开源的MPEG-4和MPEG-2 AAC解码器，它是根据GPLV2许可证授权的。

官网地址：https://www.audiocoding.com/faad2.html

## 如何在YoC平台下编译使用

- 1、将faad编解码库拷贝到YoC components文件夹下
- 2、在main函数中通过调用ad_register_faad接口注册解码器(调用播放器接口之前)，如修改solutions/xxx_demo/app/src/app_main.c，添加如下代码：

```c
extern int ad_register_faad();
int main(int argc, char *argv[])
{
    board_yoc_init();
    LOGI(TAG, "build time: %s, %s", __DATE__, __TIME__);
    ad_register_faad();

    cli_reg_cmd_xplayer();
    event_subscribe(EVENT_NETMGR_GOT_IP, network_event, NULL);
    event_subscribe(EVENT_NETMGR_NET_DISCON, network_event, NULL); 
    aos_loop_run();
}
```

- 3、修改solutions/xxx_demo/package.yaml，需加入如下配置项：

```c
#depends段增加组件依赖
depends:
  - faad: v7.4.0

#宏定义段使能faad解码
def_config:
  CONFIG_DECODER_FAAD: 1
```

## 如何在Linux平台(media_service仓库)下编译使用

Linux下编译采用cmake构建系统(不同于YoC平台)
- 1、Linux下编译前三步同YoC平台下编译

- 2、修改components/av/CMakeLists.txt，包含faad组件头文件路径及将ad_faad.c加入源文件列表(LIBSOURCE标记)中进行编译并开启faad编译宏配置：
```c
INCLUDE_DIRECTORIES(../faad/include)

ADD_DEFINITIONS(
    -DCONFIG_DECODER_FAAD=1

SET(LIBSOURCE 
    ../faad/ad_faad.c
```

- 3、修改media_service根目录下的CMakeLists.txt，编译包含faad组件：
```c
ADD_SUBDIRECTORY(components/faad)
```
- 4、修改solutions/media_service/CMakeLists.txt，链接时包含faad库：
```c
LINK_LIBRARIES(av
               uservice
               asound
               pvmp3dec
               amrnb
               amrwb
               flac
               ogg 
               opus
               speex
               faad
               sonic
               speexdsp
               mbedtls
               ulog
               base
               dbus-1
               rt  
               m
               pthread
)
```


