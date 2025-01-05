//
//  VideoWriter.hpp
//  Transcode
//
//  Created by 刘东旭 on 2024/11/24.
//

#ifndef VideoWriter_hpp
#define VideoWriter_hpp

#include <stdio.h>
#include "LXVideoFrame.hpp"

struct AVFormatContext;
struct AVCodecContext;
struct AVFrame;
class VideoWriter {
    
public:
    VideoWriter();
    ~VideoWriter();
    void OpenFile(const char *filePath);
    bool StartFileWriter(int width, int height);
    bool WriterAVFrame(AVFrame *frame);
    bool WriterVideoFrame(LXVideoFrame *videoFrame);
    void WriterTrailer();
    const char *filePath = nullptr;
private:
    AVFormatContext* formatCtx = nullptr;
    AVCodecContext* codecCtx = nullptr;
};

#endif /* VideoWriter_hpp */
