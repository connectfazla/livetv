import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/channel.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  const PlayerScreen({super.key, required this.channel});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.channel.url));
      _videoController = controller;
      await controller.initialize();

      _chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        isLive: true,
        allowFullScreen: true,
        aspectRatio: controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio,
        errorBuilder: (context, message) => Center(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      );
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B0F),
        elevation: 0,
        title: Text(widget.channel.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F1720), Color(0xFF081018)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _error != null
                            ? Container(
                                color: const Color(0xFF090C12),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Text(
                                      'Failed to play stream:\n$_error',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 15),
                                    ),
                                  ),
                                ),
                              )
                            : _chewieController != null
                                ? Chewie(controller: _chewieController!)
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF00E676),
                                      strokeWidth: 4,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ChannelInfo(channel: widget.channel),
                  const SizedBox(height: 14),
                  _StreamDetails(channel: widget.channel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelInfo extends StatelessWidget {
  final Channel channel;
  const _ChannelInfo({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1319),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A2430)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  channel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  channel.category ?? 'Live Sports',
                  style: const TextStyle(
                    color: Color(0xFF7F9CB0),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Color(0xFF00E676),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamDetails extends StatelessWidget {
  final Channel channel;
  const _StreamDetails({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1319),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A2430)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sports_soccer, color: Color(0xFF00E676), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Streaming live from ${channel.category ?? 'sports channel'}.',
              style: const TextStyle(
                color: Color(0xFFB0C6D8),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const Icon(Icons.fullscreen, color: Color(0xFF4A6A7A), size: 20),
        ],
      ),
    );
  }
}
