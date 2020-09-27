/*
 * Copyright (C) 2018-2020 Alibaba Group Holding Limited
 */

#if defined(CONFIG_DECODER_FAAD) && CONFIG_DECODER_FAAD

#include "avutil/common.h"
#include "avutil/byte_rw.h"
#include "avformat/adts_rw.h"
#include "avcodec/ad_cls.h"
#include "faad.h"

#define TAG                    "ad_faad"

struct ad_faad_priv {
    faacDecHandle         handle;
    uint8_t               inited;
    unsigned char         channels;
    unsigned long         sample_rate;
};

static int _faad_open(struct ad_faad_priv *priv, uint8_t *extradata, size_t extradata_size)
{
    int rc;
    faacDecHandle handle;
    faacDecConfigurationPtr config;

    handle = faacDecOpen();
    CHECK_RET_TAG_WITH_RET(handle, -1);

    config = faacDecGetCurrentConfiguration(handle);
    config->outputFormat = FAAD_FMT_16BIT;
    config->downMatrix   = 0;
    faacDecSetConfiguration(handle, config);

    if (extradata_size && extradata) {
        uint32_t value;

        value = byte_r16be(extradata);
        /* syncword */
        if ((value & 0xfff0) != 0xfff0) {
            m4a_cnf_t m4ac;
            uint8_t adts_hdr[ADTS_HDR_SIZE];

            rc = m4a_decode_asc(&m4ac, extradata, extradata_size);
            CHECK_RET_TAG_WITH_GOTO(rc == 0, err);

            rc = adts_hdr_encode(&m4ac, adts_hdr, 64);
            CHECK_RET_TAG_WITH_GOTO(rc == 0, err);

            rc = faacDecInit(handle, adts_hdr, ADTS_HDR_SIZE, &priv->sample_rate, &priv->channels);
        } else {
            rc = faacDecInit(handle, extradata, extradata_size, &priv->sample_rate, &priv->channels);
        }
        CHECK_RET_TAG_WITH_GOTO(rc == 0, err);
        priv->inited = 1;
    }

    priv->handle = handle;
    return 0;
err:
    if (handle)
        faacDecClose(handle);
    return -1;
}

static int _ad_faad_open(ad_cls_t *o)
{
    int rc;
    int bits = 16;
    struct ad_faad_priv *priv;

    priv = aos_zalloc(sizeof(struct ad_faad_priv));
    CHECK_RET_TAG_WITH_RET(priv, -1);

    rc = _faad_open(priv, o->ash.extradata, o->ash.extradata_size);
    CHECK_RET_TAG_WITH_GOTO(rc == 0, err);
    if (priv->inited)
        o->ash.sf =  sf_make_channel(priv->channels) | sf_make_rate(priv->sample_rate) | sf_make_bit(bits) | sf_make_signed(bits > 8);
    o->priv   = priv;

    return 0;
err:
    aos_free(priv);
    return -1;
}

static int _ad_faad_decode(ad_cls_t *o, avframe_t *frame, int *got_frame, const avpacket_t *pkt)
{
    int ret = -1;
    sf_t sf;
    int bits = 16;
    void *sample_data;
    faacDecFrameInfo frame_info;
    struct ad_faad_priv *priv = o->priv;
    faacDecHandle handle      = priv->handle;

    if (!priv->inited) {
        /* FIXME: patch for no extrdata for AILAB, adts required */
        ret = faacDecInit(handle, pkt->data, ADTS_HDR_SIZE, &priv->sample_rate, &priv->channels);
        CHECK_RET_TAG_WITH_GOTO(ret == 0, quit);
        priv->inited = 1;
        o->ash.sf    = sf_make_channel(priv->channels) | sf_make_rate(priv->sample_rate) | sf_make_bit(bits) | sf_make_signed(bits > 8);
    }

    sample_data = faacDecDecode(handle, &frame_info, pkt->data, pkt->len);
    if (frame_info.error != 0) {
        LOGE(TAG, "aac decode fail. %s", faacDecGetErrorMessage(frame_info.error));
        goto quit;
    }

    if (sample_data && (frame_info.samples > 0)) {
        sf        = sf_make_channel(frame_info.channels) | sf_make_rate(frame_info.samplerate) |
                    sf_make_bit(bits) | sf_make_signed(bits > 8);
        o->ash.sf = sf;
        frame->sf = sf;
        frame->nb_samples = frame_info.samples / frame_info.channels;

        ret = avframe_get_buffer(frame);
        if (ret < 0) {
            LOGD(TAG, "avframe_get_buffer failed, may be oom. sf = %u, ch = %d, rate = %d\n", sf,
                 frame_info.channels, frame_info.samplerate);
            goto quit;
        }

        memcpy((void*)frame->data[0], sample_data, frame_info.samples * (16 / 8));
        *got_frame = 1;
    }

    ret = frame_info.bytesconsumed;

quit:
    return ret;
}

static int _ad_faad_control(ad_cls_t *o, int cmd, void *arg, size_t *arg_size)
{
    //TODO
    return 0;
}

#if 0
static int _ad_faad_reset(ad_cls_t *o)
{
    struct ad_faad_priv *priv = o->priv;
    faacDecHandle handle      = priv->handle;

    faacDecPostSeekReset(handle, -1);

    return 0;
}
#else
static int _ad_faad_reset(ad_cls_t *o)
{
    int rc;
    struct ad_faad_priv *priv = o->priv;
    faacDecHandle handle      = priv->handle;

    faacDecClose(handle);
    priv->handle = NULL;
    priv->inited = 0;
    rc = _faad_open(priv, o->ash.extradata, o->ash.extradata_size);

    return rc;
}
#endif

static int _ad_faad_close(ad_cls_t *o)
{
    struct ad_faad_priv *priv = o->priv;
    faacDecHandle handle      = priv->handle;

    faacDecClose(handle);

    aos_free(priv);
    o->priv = NULL;
    return 0;
}

const struct ad_ops ad_ops_faad = {
    .name           = "faad",
    .id             = AVCODEC_ID_AAC,

    .open           = _ad_faad_open,
    .decode         = _ad_faad_decode,
    .control        = _ad_faad_control,
    .reset          = _ad_faad_reset,
    .close          = _ad_faad_close,
};

#endif

