#include "LXDebugFrame.h"
#import "FormatUtils.h"

void DebugFrame(AVFrame *frame) {
    CVPixelBufferRef buffer = [FormatUtils CreatPixelBufferWithAVFrame:frame];
    NSLog(@"DebugFrame: %@", buffer);
}