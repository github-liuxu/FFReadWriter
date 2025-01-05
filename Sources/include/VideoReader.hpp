//
//  VideoReader.hpp
//  Transcode
//
//  Created by 刘东旭 on 2024/11/28.
//

#ifndef CVideoReader_hpp
#define CVideoReader_hpp

#include <stdio.h>
#include <string>
#include "LXVideoFrame.hpp"

struct AVFormatContext;
struct AVCodecContext;
struct AVFrame;

class VideoReader {
public:
    VideoReader();
    ~VideoReader();
    bool Open(const std::string& filename);
    void SetRange(int64_t start, int64_t end);
    void Close();
    AVFrame* ReadAVFrame();
    LXVideoFrame* ReadVideoFrame();
    int GetWidth() const;
    int GetHeight() const;
    int64_t GetBitrate();
    int64_t GetDuration() const;
    bool Seek(int64_t timestamp);
private:
    AVFormatContext* formatContext;
    AVCodecContext* codecContext;
    int videoStreamIndex;
    int64_t bitRate;
    int64_t m_start, m_end;
};


#endif /* CVideoReader_hpp */
