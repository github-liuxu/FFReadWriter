//
//  LXFrameUtils.cpp
//  
//
//  Created by 刘东旭 on 2025/1/1.
//

#include "LXFrameUtils.hpp"

LXVideoFrame *GetVideoFrame(AVFrame *frame) {
    if (frame == nullptr) {
        return nullptr;
    }
    LXVideoFrame *videoFrame = new LXVideoFrame();
    LXFrameBuffer *frameBuffer = videoFrame->GetFrameBuffer();
    memcpy(frameBuffer->linesize, frame->linesize, sizeof(frame->linesize));
    frameBuffer->width = frame->width;
    frameBuffer->height = frame->height;
    frameBuffer->format = AV_PIX_FMT_YUV420P;
    frameBuffer->data[0] = (uint8_t *)malloc(frame->height * frame->linesize[0]);
    frameBuffer->data[1] = (uint8_t *)malloc(frame->height * frame->linesize[1] / 2);
    frameBuffer->data[2] = (uint8_t *)malloc(frame->height * frame->linesize[2] / 2);
    memcpy(frameBuffer->data[0], frame->data[0], frame->linesize[0] * frame->height);
    memcpy(frameBuffer->data[1], frame->data[1], frame->linesize[1] * frame->height / 2);
    memcpy(frameBuffer->data[2], frame->data[2], frame->linesize[2] * frame->height / 2);
    return videoFrame;
}


AVFrame *GetAVFrame(LXVideoFrame *videoFrame) {
    if (videoFrame == nullptr) {
        return nullptr;
    }
    AVFrame *frame = av_frame_alloc();
    frame->format = videoFrame->GetFrameBuffer()->format;
    frame->width = videoFrame->GetFrameBuffer()->width;
    frame->height = videoFrame->GetFrameBuffer()->height;
    if (av_frame_get_buffer(frame, 32) < 0) {
        fprintf(stderr, "Could not allocate frame data\n");
    }
    LXFrameBuffer* frameBuffer = videoFrame->GetFrameBuffer();
    memcpy(frame->data[0], frameBuffer->data[0], frameBuffer->linesize[0]);
    memcpy(frame->data[1], frameBuffer->data[1], frameBuffer->linesize[1]);
    memcpy(frame->data[2], frameBuffer->data[2], frameBuffer->linesize[2]);
    return frame;
}
