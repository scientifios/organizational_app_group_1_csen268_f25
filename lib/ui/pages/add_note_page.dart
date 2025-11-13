import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../state/tasks_cubit.dart';

class AddNotePage extends StatefulWidget {
  final String taskId;
  const AddNotePage({super.key, required this.taskId});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late final TextEditingController controller;
  AudioRecorder? _recorder;
  final AudioPlayer _player = AudioPlayer();
  late StreamSubscription<void> _playerCompleteSub;
  bool _isRecording = false;
  String? _playingClip;
  List<String> _audioClips = const [];
  late final bool _supportsRecording;

  @override
  void initState() {
    super.initState();
    final task = context.read<TasksCubit>().state.tasks.firstWhere((t)=> t.id == widget.taskId);
    controller = TextEditingController(text: task.note ?? '');
    _audioClips = List<String>.from(task.audioClips);
    _supportsRecording = !kIsWeb;
    if (_supportsRecording) {
      _recorder = AudioRecorder();
    }
    _playerCompleteSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingClip = null);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _recorder?.dispose();
    _playerCompleteSub.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_supportsRecording || _recorder == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording is only available on mobile/desktop builds.')),
        );
      }
      return;
    }
    if (_isRecording) {
      final path = await _recorder!.stop();
      if (path != null) {
        setState(() => _isRecording = false);
        await _storeClip(path);
      } else {
        setState(() => _isRecording = false);
      }
      return;
    }

    final hasPermission = await _recorder!.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required.')),
        );
      }
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = '${dir.path}/voice_$timestamp.m4a';

    await _recorder!.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: targetPath,
    );
    setState(() => _isRecording = true);
  }

  Future<void> _storeClip(String path) async {
    setState(() => _audioClips = [..._audioClips, path]);
    context.read<TasksCubit>().addAudioClip(widget.taskId, path);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice note saved.')),
      );
    }
  }

  Future<void> _playClip(String path) async {
    if (_playingClip == path) {
      await _player.stop();
      setState(() => _playingClip = null);
      return;
    }
    await _player.stop();
    await _player.play(DeviceFileSource(path));
    setState(() => _playingClip = path);
  }

  void _removeClip(String path) {
    context.read<TasksCubit>().removeAudioClip(widget.taskId, path);
    setState(() => _audioClips = _audioClips.where((clip) => clip != path).toList());
  }

  String _fileLabel(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isNotEmpty ? parts.last : path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: ()=> context.pop()), title: const Text('Add note')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Write something...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_audioClips.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voice notes', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: _audioClips.length,
                            itemBuilder: (_, index) {
                              final clip = _audioClips[index];
                              final isPlaying = _playingClip == clip;
                              return Card(
                                child: ListTile(
                                  leading: IconButton(
                                    icon: Icon(isPlaying ? Icons.stop_circle_outlined : Icons.play_arrow),
                                    onPressed: () => _playClip(clip),
                                  ),
                                  title: Text(_fileLabel(clip)),
                                  subtitle: Text(isPlaying ? 'Playing' : 'Tap to listen'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _removeClip(clip),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  if (_isRecording)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: const [
                          SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          SizedBox(width: 8),
                          Text('Recording...'),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              IconButton(onPressed: (){}, icon: const Icon(Icons.add_photo_alternate_outlined)),
              IconButton(onPressed: (){}, icon: const Icon(Icons.photo_camera_outlined)),
              Tooltip(
                message: _supportsRecording
                    ? (_isRecording ? 'Tap to stop recording' : 'Record a voice note')
                    : 'Recording unavailable on web preview',
                child: IconButton(
                  onPressed: _toggleRecording,
                  icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic_none_outlined),
                  color: _isRecording ? Theme.of(context).colorScheme.error : null,
                ),
              ),
              const Spacer(),
              FilledButton(onPressed: (){
                context.read<TasksCubit>().setNote(widget.taskId, controller.text);
                context.pop();
              }, child: const Text('Save'))
            ])
          ],
        ),
      ),
    );
  }
}
