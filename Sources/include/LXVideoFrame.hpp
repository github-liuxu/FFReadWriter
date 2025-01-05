//
//  LXVideoFrame.hpp
//  Composition
//
//  Created by 刘东旭 on 2024/7/7.
//

#ifndef LXVideoFrame_hpp
#define LXVideoFrame_hpp
#include <stdio.h>
#include <stdint.h>

struct LXFrameBuffer {
    uint8_t *data[8];
    int linesize[8];
    int width;
    int height;
    int format; //enum AVPixelFormat
};

struct IVideoFrame {
    virtual LXFrameBuffer* GetFrameBuffer() = 0;
    virtual void SetFrameBuffer(LXFrameBuffer* buffer) = 0;
    virtual void SetPts(int64_t in_fileTime) = 0;
    virtual int64_t GetPts() = 0;
};
class LXVideoFrame: public IVideoFrame {
public:
    LXVideoFrame();
    LXVideoFrame* Copy();
    ~LXVideoFrame();
    
    LXFrameBuffer* GetFrameBuffer();
    
    void SetFrameBuffer(LXFrameBuffer* buffer);
    
    void SetPts(int64_t in_fileTime);
    
    int64_t GetPts();
    int texture = 0;
private:
    LXFrameBuffer* frameBuffer;
    int64_t in_fileTime = 0;
};

#endif /* LXVideoFrame_hpp */
