//
//  FormatUtils.m
//  FFmpegPlayer
//
//  Created by 刘东旭 on 2023/4/28.
//

#import "FormatUtils.h"
#include "LXVideoFrame.hpp"
extern "C" {
    #include <libavformat/avformat.h>
    #include <libavutil/imgutils.h>
    #include <libswscale/swscale.h>
    #include <libavcodec/avcodec.h>
}
@implementation FormatUtils

+ (CVPixelBufferRef)CreatPixelBufferWithAVFrame:(AVFrame*)frame {
    CVPixelBufferRef pixelBuffer = nil;
    NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};

    if (frame->format == AV_PIX_FMT_BGRA) {
        //未测试
        CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if(theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferCreate Failed");
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t bytesPerRowBGRA = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        memcpy(base, frame->data[0], bytesPerRowBGRA * frame->height);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    } else if (frame->format == AV_PIX_FMT_NV12) {
        CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if(theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t bytesPerRowY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t bytesPerRowUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        memcpy(base, frame->data[0], bytesPerRowY * frame->height);
        base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        memcpy(base, frame->data[1], bytesPerRowUV * frame->height/2);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
   } else if (frame->format == AV_PIX_FMT_YUV420P) {
       CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_420YpCbCr8Planar, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
       if(theError != kCVReturnSuccess){
           NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
       }
       CVPixelBufferLockBaseAddress(pixelBuffer, 0);
       
       unsigned char *yDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
       unsigned char *cbDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
       unsigned char *crDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2);

       // set the bytes per row for each plane
       size_t yDestBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
       size_t cbDestBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
       size_t crDestBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 2);

       // set the pointers to the AVFrame's data for each plane
       unsigned char *ySrcPlane = frame->data[0];
       unsigned char *cbSrcPlane = frame->data[1];
       unsigned char *crSrcPlane = frame->data[2];

       // set the bytes per row for each plane of the AVFrame
       size_t ySrcBytesPerRow = frame->linesize[0];
       size_t cbSrcBytesPerRow = frame->linesize[1];
       size_t crSrcBytesPerRow = frame->linesize[2];
       for (int i = 0; i < frame->height; i++) {
           memcpy(yDestPlane + i * yDestBytesPerRow, ySrcPlane + i * ySrcBytesPerRow, frame->width);
       }

       for (int i = 0; i < frame->height / 2; i++) {
           memcpy(cbDestPlane + i * cbDestBytesPerRow, cbSrcPlane + i * cbSrcBytesPerRow, frame->width / 2);
           memcpy(crDestPlane + i * crDestBytesPerRow, crSrcPlane + i * crSrcBytesPerRow, frame->width / 2);
       }
       CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    } else {
        CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if(theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
        }
        int linesize[4];
        uint8_t* data[4];
        struct SwsContext *swsContext = NULL;
        swsContext = sws_getContext(frame->width, frame->height, AVPixelFormat(frame->format), frame->width, frame->height, AV_PIX_FMT_NV12, SWS_BILINEAR, NULL, NULL, NULL);
        av_image_alloc(data, linesize, frame->width, frame->height, AV_PIX_FMT_NV12, 1);
        sws_scale(swsContext, frame->data, frame->linesize, 0, frame->height, data, linesize);
        sws_freeContext(swsContext);
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t bytesPerRowY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t bytesPerRowUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        for (int i = 0; i < frame->height; i++) {
            memcpy((uint8_t*)base + (i * bytesPerRowY), (uint8_t*)data[0] + (i * linesize[0]), frame->width);
        }
        base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        for (int i = 0; i < frame->height / 2; i++) {
            memcpy((uint8_t*)base + (i * bytesPerRowUV), (uint8_t*)data[1] + (i * linesize[1]), frame->width);
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        av_free(data[0]);
    }
    return pixelBuffer;
}

+ (CVPixelBufferRef)CreatPixelBufferWithFrameBuffer:(LXFrameBuffer*)frame {
    CVPixelBufferRef pixelBuffer = nil;
    NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};

    if (frame->format == AV_PIX_FMT_BGRA) {
        //未测试
        CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if(theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferCreate Failed");
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t bytesPerRowBGRA = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        memcpy(base, frame->data[0], bytesPerRowBGRA * frame->height);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    } else if (frame->format == AV_PIX_FMT_NV12) {
        CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if(theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t bytesPerRowY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t bytesPerRowUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        memcpy(base, frame->data[0], bytesPerRowY * frame->height);
        base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        memcpy(base, frame->data[1], bytesPerRowUV * frame->height/2);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    } else if (frame->format == AV_PIX_FMT_YUV420P) {
        CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_420YpCbCr8Planar, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if(theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        unsigned char *yDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        unsigned char *cbDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        unsigned char *crDestPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2);

        // set the bytes per row for each plane
        size_t yDestBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t cbDestBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        size_t crDestBytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 2);

        // set the pointers to the AVFrame's data for each plane
        unsigned char *ySrcPlane = frame->data[0];
        unsigned char *cbSrcPlane = frame->data[1];
        unsigned char *crSrcPlane = frame->data[2];

        // set the bytes per row for each plane of the AVFrame
        size_t ySrcBytesPerRow = frame->linesize[0];
        size_t cbSrcBytesPerRow = frame->linesize[1];
        size_t crSrcBytesPerRow = frame->linesize[2];
        for (int i = 0; i < frame->height; i++) {
            memcpy(yDestPlane + i * yDestBytesPerRow, ySrcPlane + i * ySrcBytesPerRow, frame->width);
        }

        for (int i = 0; i < frame->height / 2; i++) {
            memcpy(cbDestPlane + i * cbDestBytesPerRow, cbSrcPlane + i * cbSrcBytesPerRow, frame->width / 2);
            memcpy(crDestPlane + i * crDestBytesPerRow, crSrcPlane + i * crSrcBytesPerRow, frame->width / 2);
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    } else {
        CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, frame->width, frame->height, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
        if(theError != kCVReturnSuccess){
            NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
        }
        int linesize[4];
        uint8_t* data[4];
        struct SwsContext *swsContext = NULL;
        swsContext = sws_getContext(frame->width, frame->height, AVPixelFormat(frame->format), frame->width, frame->height, AV_PIX_FMT_NV12, SWS_BILINEAR, NULL, NULL, NULL);
        av_image_alloc(data, linesize, frame->width, frame->height, AV_PIX_FMT_NV12, 1);
        sws_scale(swsContext, frame->data, frame->linesize, 0, frame->height, data, linesize);
        sws_freeContext(swsContext);
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        size_t bytesPerRowY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        size_t bytesPerRowUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        for (int i = 0; i < frame->height; i++) {
            memcpy((uint8_t*)base + (i * bytesPerRowY), (uint8_t*)data[0] + (i * linesize[0]), frame->width);
        }
        base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        for (int i = 0; i < frame->height / 2; i++) {
            memcpy((uint8_t*)base + (i * bytesPerRowUV), (uint8_t*)data[1] + (i * linesize[1]), frame->width);
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        av_free(data[0]);
    }
    return pixelBuffer;
}

+ (CVPixelBufferRef)CreatPixelBufferWithData:(uint8_t *)data width:(int)width height:(int)height {
    CVPixelBufferRef pixelBuffer = nil;
    NSDictionary *pixelAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey : @{}};
    //未测试
    CVReturn theError = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)pixelAttributes, &pixelBuffer);
    if(theError != kCVReturnSuccess){
        NSLog(@"CVPixelBufferCreate Failed");
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    size_t bytesPerRowBGRA = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    memcpy(base, data, bytesPerRowBGRA * height);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return pixelBuffer;
}

@end
