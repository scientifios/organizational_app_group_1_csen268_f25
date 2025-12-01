import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this);
  Timer? _fallbackTimer;
  Timer? _fadeTimer;
  bool _navigated = false;
  bool _fading = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatusChanged);
    // Initial guard in case animation fails to load.
    _fallbackTimer = Timer(const Duration(seconds: 3), _goNextIfMounted);
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _fadeTimer?.cancel();
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _goNextIfMounted();
    }
  }

  void _goNextIfMounted() {
    if (!mounted || _navigated) return;
    _navigated = true;
    _fallbackTimer?.cancel();
    if (!_fading) {
      setState(() => _fading = true);
    }
    // Decide your next route: to login for unauthenticated flow.
    _fadeTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/login');
      });
    });
  }

  // 👇 dotLottie 自定义解码器
  Future<LottieComposition?> _dotLottieDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(
      bytes,
      filePicker: (files) {
        // 你的 .lottie 里就是  animations/xxx.json  这种结构
        return files.firstWhere(
          (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('=== SplashPage build ===');
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedOpacity(
        opacity: _fading ? 0 : 1,
        duration: const Duration(milliseconds: 250),
        child: Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: Lottie.asset(
              'assets/animations/Water_Loading_Animation.json',
              controller: _controller,
              repeat: false,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('=== Lottie error: $error ===');
                // If the Lottie fails to parse/play, skip animation quickly.
                _goNextIfMounted();
                return const SizedBox.shrink();
              },
              onLoaded: (composition) {
                debugPrint('=== Lottie loaded: ${composition.duration} ===');
                // Guard against malformed compositions with zero duration.
                if (composition.duration == Duration.zero) {
                  _goNextIfMounted();
                  return;
                }
                // Play for the animation duration (clamped to 1.2s–5s),
                // then navigate.
                final playMs =
                    composition.duration.inMilliseconds.clamp(1200, 5000);
                _controller.duration = Duration(milliseconds: playMs);
                _controller.reset();
                _controller.forward();
                _fallbackTimer?.cancel();
                _fallbackTimer =
                    Timer(Duration(milliseconds: playMs + 200), _goNextIfMounted);
              },
            ),
          ),
        ),
      ),
    );
  }
}
