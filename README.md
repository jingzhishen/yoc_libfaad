## 简介

该组件基于平头哥YoC平台使用faad以支持aac编解码功能。

FAAD2是一个开源的MPEG-4和MPEG-2 AAC解码器，它是根据GPLV2许可证授权的。

官网地址：https://www.audiocoding.com/faad2.html

## 如何在YoC平台下编译使用

- 将faad编解码库拷贝到YoC components文件夹下
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

- 修改components/av/include/avcodec/avcodec_all.h，修改ad_register_all函数，加入faad解码支持，代码如下：

```c
static inline int ad_register_all()
{
    ...

#if defined(CONFIG_DECODER_FAAD)
    REGISTER_DECODER(FAAD, faad);
#endif

    return 0;
}
```

- 修改solutions/tg6101_cpu1_demo/package.yaml，需加入如下配置项：

```c
#depends段增加组件依赖
depends:
  - faad: v7.4.0

#宏定义段使能faad解码
def_config:
  CONFIG_DECODER_FAAD: 1
```
