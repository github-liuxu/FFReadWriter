#include "LXAVFrameConvert.hpp"
extern "C" {
    #include <libavformat/avformat.h>
    #include <libswscale/swscale.h>
    #include <libavutil/imgutils.h>
}

LXAVFrameConvert::LXAVFrameConvert() {

}

LXAVFrameConvert::~LXAVFrameConvert() {
    if (swsContext != NULL)
    {
        sws_freeContext(swsContext);
        swsContext = NULL;
    }
}

AVFrame* LXAVFrameConvert::Convert(AVFrame* frame, LXPixelType pixelType) {
    int linesize[4];
    uint8_t* data[4];
    if (m_pixelType != pixelType) {
        sws_freeContext(swsContext);
        swsContext = NULL;
    }
    m_pixelType = pixelType;
    AVPixelFormat format = AV_PIX_FMT_NV12;
    if (m_pixelType == kPixelTypeYUV420P) {
        format = AV_PIX_FMT_YUV420P;
    } else if (m_pixelType == kPixelTypeNV12) {
        format = AV_PIX_FMT_NV12;
    } else if (m_pixelType == kPixelTypeNV21) {
        format = AV_PIX_FMT_NV21;
    } else if (m_pixelType == kPixelTypeARGB32) {
        format = AV_PIX_FMT_RGBA;
    }
    
    if (swsContext == NULL && frame) {
        swsContext = sws_getContext(frame->width, frame->height, AVPixelFormat(frame->format), frame->width, frame->height, format, SWS_BILINEAR, NULL, NULL, NULL);
    }
    av_image_alloc(data, linesize, frame->width, frame->height, format, 1);
    sws_scale(swsContext, frame->data, frame->linesize, 0, frame->height, data, linesize);
    AVFrame* newFrame = av_frame_alloc();
    newFrame->format = format;
    newFrame->width = frame->width;
    newFrame->height = frame->height;
    av_image_fill_arrays(newFrame->data, newFrame->linesize, data[0], format, frame->width, frame->height, 1);
    return newFrame;
}