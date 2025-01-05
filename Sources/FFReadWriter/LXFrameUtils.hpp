//
//  LXFrameUtils.hpp
//  
//
//  Created by 刘东旭 on 2025/1/1.
//

#ifndef LXFrameUtils_hpp
#define LXFrameUtils_hpp

#include <stdio.h>
#include "LXVideoFrame.hpp"
extern "C" {
    #include <libavutil/frame.h>
}

LXVideoFrame *GetVideoFrame(AVFrame *frame);
AVFrame *GetAVFrame(LXVideoFrame *videoFrame);


#endif /* LXFrameUtils_hpp */
