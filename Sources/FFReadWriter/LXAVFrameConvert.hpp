#ifndef LXAVFrameConvert_hpp
#define LXAVFrameConvert_hpp
#include <stdio.h>
#include <LXVideoFrame.hpp>

struct AVFrame;
struct SwsContext;

class LXAVFrameConvert {
public:
    LXAVFrameConvert();
    ~LXAVFrameConvert();

    AVFrame* Convert(AVFrame* frame, LXPixelType pixelType);
private:
    struct SwsContext *swsContext = NULL;
    LXPixelType m_pixelType;
};
#endif /* LXAVFrameConvert_hpp */