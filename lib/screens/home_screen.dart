import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Channel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ChannelService.fetchChannels();
  }

  Future<void> _refresh() async {
    setState(() => _future = ChannelService.fetchChannels());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live TV')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Channel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(message: '${snapshot.error}', onRetry: _refresh);
            }
            final channels = snapshot.data ?? [];
            if (channels.isEmpty) {
              return const Center(child: Text('No channels found'));
            }
            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, i) {
                final c = channels[i];
                return ListTile(
                  leading: c.logo.isNotEmpty
                      ? Image.network(
                          c.logo,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.tv, size: 40),
                        )
                      : const Icon(Icons.tv, size: 40),
                  title: Text(c.name),
                  subtitle: c.category != null ? Text(c.category!) : null,
                  trailing: const Icon(Icons.play_circle_fill),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(channel: c),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // Wrapped in a ListView so pull-to-refresh still works on the error state.
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Center(child: Text('Could not load channels')),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        Center(
          child: ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}
