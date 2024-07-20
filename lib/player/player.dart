import 'dart:io';

import 'package:drawing_sketch/constant/color.dart';
import 'package:drawing_sketch/static/apis.dart';
import 'package:drawing_sketch/widgets/images.dart';
import 'package:drawing_sketch/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({super.key, required this.path});

  final String path;

  @override
  PlayVideoState createState() => PlayVideoState();
}

class PlayVideoState extends State<PlayVideo> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool showOverLay = false;
  int _currentPosition = 0;
  int _duration = 0;
  bool isBuffering = false;
  bool muted = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _controller.pause();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      }).onError((PlatformException error, stackTrace) {
        Apis.constSnack(context, '${error.message}');
      });
    _attachListenerToController();
    _controller.setLooping(true);
    _controller.play();
  }

  _attachListenerToController() {
    _controller.addListener(
      () {
        isBuffering = _controller.value.isBuffering;
        if (mounted) {
          setState(() {
            _currentPosition = _controller.value.duration.inMilliseconds == 0 ? 0 : _controller.value.position.inMilliseconds;
            _duration = _controller.value.duration.inMilliseconds;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget moviePoster = Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        VideoPlayer(_controller),
        Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  showOverLay = !showOverLay;
                });
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 50),
              reverseDuration: const Duration(milliseconds: 200),
              child: showOverLay
                  ? InkWell(
                      onTap: () {
                        showOverLay = !showOverLay;
                        setState(() {});
                      },
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(muted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    if (_controller.value.volume == 0) {
                                      _controller.setVolume(1.0);
                                    } else {
                                      _controller.setVolume(0.0);
                                    }
                                    muted = !muted;
                                  });
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    ConstText(durationFormatter(_currentPosition), fontSize: 16.sp, color: whiteColor, fontFamily: 'M'),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: VideoProgressIndicator(
                                        _controller,
                                        allowScrubbing: true,
                                        colors: const VideoProgressColors(playedColor: pinkColor, backgroundColor: greyColor),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    ConstText(durationFormatter(_duration), fontSize: 16.sp, fontFamily: 'M', color: whiteColor),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h)
                            ],
                          ),
                          Center(
                            child: RawMaterialButton(
                              padding: const EdgeInsets.all(10),
                              fillColor: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 5,
                              child: Icon(
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.black,
                                size: 30.h,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                                  showOverLay = _controller.value.isPlaying ? false : true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        Visibility(
          visible: isBuffering,
          child: const Center(
            child: CircularProgressIndicator(color: pinkColor),
          ),
        )
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const ConstText('Creation', fontFamily: "B"),
        leading: ConstSvg(
          "assets/svg/back.svg",
          height: 24.w,
          width: 24.w,
          fit: BoxFit.scaleDown,
          color: blackColor,
          onTap: () {
            Get.back();
          },
        ),
      ),
      body: Center(child: moviePoster),
    );
  }
}

String durationFormatter(int milliseconds) {
  int seconds = milliseconds ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds %= 3600;
  final minutes = seconds ~/ 60;
  seconds %= 60;

  final hoursString = hours > 0 ? hours.toString() : '';
  final minutesString = minutes.toString().padLeft(2, '0');
  final secondsString = seconds.toString().padLeft(2, '0');
  final formattedTime = '${hoursString.isNotEmpty ? '$hoursString:' : ''}$minutesString:$secondsString';

  return formattedTime;
}
