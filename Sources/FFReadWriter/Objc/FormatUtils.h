//
//  FormatUtils.h
//  FFmpegPlayer
//
//  Created by 刘东旭 on 2023/4/28.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
struct AVFrame;
struct LXFrameBuffer;

NS_ASSUME_NONNULL_BEGIN

@interface FormatUtils : NSObject

+ (CVPixelBufferRef)CreatPixelBufferWithAVFrame:(AVFrame*)frame;

+ (CVPixelBufferRef)CreatPixelBufferWithFrameBuffer:(LXFrameBuffer *)frame;

+ (CVPixelBufferRef)CreatPixelBufferWithData:(uint8_t *)data width:(int)width height:(int)height;

@end

NS_ASSUME_NONNULL_END
