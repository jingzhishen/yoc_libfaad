## 简介

该组件基于平头哥YoC平台使用faad以支持aac编解码功能。

FAAD2是一个开源的MPEG-4和MPEG-2 AAC解码器，它是根据GPLV2许可证授权的。

官网地址：https://www.audiocoding.com/faad2.html

项目链接：https://code.aliyun.com/jingzhishen/yoc_faad

## 如何在YoC平台下编译使用

- 将faad编解码库拷贝到YoC components文件夹下
- 将ad_faad.c拷贝到components/av/avcodec文件夹下
- 修改av组件中的package.yaml文件，将该文件加入到源文件编译列表中。同时在depends项中加入faad依赖。
- 修改components/av/avcodec/avcodec_all.c，添加如下代码：

```c
/**
 * @brief  regist ad for faad
 * @return 0/-1
 */
int ad_register_faad()
{
    extern struct ad_ops ad_ops_faad;
    return ad_ops_register(&ad_ops_faad);
}
```

- 修改components/av/include/avcodec/avcodec_all.h，加入该函数的头文件声明。并修改ad_register_all内联函数，加入faad解码支持，代码如下：

```c
#if defined(CONFIG_DECODER_FAAD)
    REGISTER_DECODER(FAAD, faad);
#endif
```

- 修改solutions/pangu_demo/package.yaml，若使能faad解码，需加入如下配置项：

```c
CONFIG_DECODER_FAAD: 1
```

