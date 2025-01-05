//
//  VideoWriter.cpp
//  Transcode
//
//  Created by 刘东旭 on 2024/11/24.
//

#include "VideoWriter.hpp"
#include <iostream>
#include "LXFrameUtils.hpp"
extern "C" {
    #include <libavformat/avformat.h>
    #include <libavcodec/avcodec.h>
    #include <libswresample/swresample.h>
    #include <libswscale/swscale.h>
    #include <libavutil/avutil.h>
}

VideoWriter::VideoWriter() {
}

void VideoWriter::OpenFile(const char *filePath) {
    this->filePath = filePath;
}

bool VideoWriter::StartFileWriter(int width, int height) {
    avformat_alloc_output_context2(&formatCtx, nullptr, nullptr, filePath);
    const AVCodec* codec = avcodec_find_encoder(AV_CODEC_ID_H264);
    codecCtx = avcodec_alloc_context3(codec);
    codecCtx->codec_type = AVMEDIA_TYPE_VIDEO;
    codecCtx->width = width;
    codecCtx->height = height;
    AVRational rat;
    rat.num = 1;
    rat.den = 30;
    codecCtx->time_base = rat;
    codecCtx->framerate = (AVRational){30, 1};
    codecCtx->gop_size = 1;
    codecCtx->pix_fmt = AV_PIX_FMT_YUV420P;

    AVStream* stream = avformat_new_stream(formatCtx, codec);
    stream->index = 0;
    stream->codecpar->codec_id = codec->id;
    stream->codecpar->codec_type = AVMEDIA_TYPE_VIDEO;
    stream->codecpar->width = width;
    stream->codecpar->height = height;
    stream->codecpar->format = codecCtx->pix_fmt;
    stream->time_base = AV_TIME_BASE_Q;
    
    AVDictionary *opts = NULL;
    avcodec_open2(codecCtx, codec, &opts);
    avcodec_parameters_from_context(stream->codecpar, codecCtx);
    stream->time_base = codecCtx->time_base;
    if (avcodec_parameters_from_context(stream->codecpar, codecCtx) < 0) {
        std::cerr << "Failed to copy codec parameters" << std::endl;
        return false;
    }
    avio_open(&formatCtx->pb, filePath, AVIO_FLAG_WRITE);
    return avformat_write_header(formatCtx, nullptr) >= 0;
}

bool VideoWriter::WriterAVFrame(AVFrame *frame) {
    int ret = avcodec_send_frame(codecCtx, frame);
    while (ret >= 0) {
        AVPacket *pkt = av_packet_alloc();
        ret = avcodec_receive_packet(codecCtx, pkt);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
            std::cout << "encodeRet:" << ret << std::endl;
            av_packet_unref(pkt);
            av_packet_free(&pkt);
            return false;
        } else if (ret < 0) {
            av_packet_unref(pkt);
            av_packet_free(&pkt);
            return false;
        }
        av_interleaved_write_frame(formatCtx, pkt);
        av_packet_unref(pkt);
        av_packet_free(&pkt);
        break;
    }
    
    return true;
}

bool VideoWriter::WriterVideoFrame(LXVideoFrame *videoFrame) {
    AVFrame *frame = GetAVFrame(videoFrame);
    frame->pts = videoFrame->GetPts();
    int ret = avcodec_send_frame(codecCtx, frame);
    while (ret >= 0) {
        AVPacket *pkt = av_packet_alloc();
        ret = avcodec_receive_packet(codecCtx, pkt);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
            std::cout << "encodeRet:" << ret << std::endl;
            av_packet_unref(pkt);
            av_packet_free(&pkt);
            break;
        } else if (ret < 0) {
            av_packet_unref(pkt);
            av_packet_free(&pkt);
            break;
        }
        av_interleaved_write_frame(formatCtx, pkt);
        av_packet_unref(pkt);
        av_packet_free(&pkt);
        break;
    }
    
    return true;
}

void VideoWriter::WriterTrailer(){
    av_write_trailer(formatCtx);
    avio_close(formatCtx->pb);
}

VideoWriter::~VideoWriter() {
    avcodec_free_context(&codecCtx);
    avformat_free_context(formatCtx);
}
