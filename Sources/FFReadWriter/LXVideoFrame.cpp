//
//  LXVideoFrame.cpp
//  
//
//  Created by 刘东旭 on 2025/1/1.
//

#include "LXVideoFrame.hpp"
extern "C" {
    #include <libavutil/frame.h>
}

LXVideoFrame::LXVideoFrame(){
    frameBuffer = new LXFrameBuffer();
}
LXVideoFrame* LXVideoFrame::Copy() {
    LXVideoFrame* videoFrame = new LXVideoFrame();
    videoFrame->frameBuffer->width = frameBuffer->width;
    videoFrame->frameBuffer->height = frameBuffer->height;
    videoFrame->frameBuffer->format = frameBuffer->format;
    memcpy(videoFrame->frameBuffer->linesize, frameBuffer->linesize, sizeof(this->frameBuffer->linesize));
    if (frameBuffer->format == AV_PIX_FMT_BGRA) {
        int size = frameBuffer->linesize[0] * frameBuffer->height * 4;
        if (size > 0) {
            uint8_t *addr = (uint8_t *)malloc(size);
            memcpy(addr, frameBuffer->data[0], size);
            videoFrame->frameBuffer->data[0] = addr;
        } else {
            videoFrame->frameBuffer->data[0] = NULL;
        }
    }
    if (frameBuffer->format == AV_PIX_FMT_NV12 || frameBuffer->format == AV_PIX_FMT_YUV420P) {
        int ysize = frameBuffer->linesize[0] * frameBuffer->height;
        int usize = frameBuffer->linesize[1] * frameBuffer->height / 2;
        int vsize = frameBuffer->linesize[2] * frameBuffer->height / 2;
        if (ysize > 0) {
            uint8_t *addr = (uint8_t *)malloc(ysize);
            memcpy(addr, frameBuffer->data[0], ysize);
            videoFrame->frameBuffer->data[0] = addr;
        } else {
            videoFrame->frameBuffer->data[0] = NULL;
        }
        if (usize > 0) {
            uint8_t *addr = (uint8_t *)malloc(usize);
            memcpy(addr, frameBuffer->data[1], usize);
            videoFrame->frameBuffer->data[1] = addr;
        } else {
            videoFrame->frameBuffer->data[1] = NULL;
        }
        if (vsize > 0) {
            uint8_t *addr = (uint8_t *)malloc(vsize);
            memcpy(addr, frameBuffer->data[2], vsize);
            videoFrame->frameBuffer->data[2] = addr;
        } else {
            videoFrame->frameBuffer->data[2] = NULL;
        }
    }

    videoFrame->SetPts(this->GetPts());
    return videoFrame;
}
LXVideoFrame::~LXVideoFrame(){
    for (int i = 0; i< 8; i++) {
        void*addr = frameBuffer->data[i];
        if (addr) {
            free(addr);
        }
    }
    delete frameBuffer;
}

LXFrameBuffer* LXVideoFrame::GetFrameBuffer() {
    return frameBuffer;
}

void LXVideoFrame::SetFrameBuffer(LXFrameBuffer* buffer) {
    this->frameBuffer = buffer;
}

void LXVideoFrame::SetPts(int64_t in_fileTime) {
    this->in_fileTime = in_fileTime;
}

int64_t LXVideoFrame::GetPts() {
    return this->in_fileTime;
}
