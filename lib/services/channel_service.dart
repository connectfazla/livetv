import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ChannelService {
  // ───────────────────────────────────────────────────────────
  // Sports M3U playlist source from the project raw GitHub link.
  // If remote parsing fails, fallback to the embedded channels JSON.
  // ───────────────────────────────────────────────────────────
  static const String channelsUrl =
      'https://raw.githubusercontent.com/connectfazla/livetv/refs/heads/main/android/football_cricket.m3u';

  static final RegExp _attributeRegExp =
      RegExp(r'([\w-]+)="([^"]*)"');

  static Future<List<Channel>> fetchChannels() async {
    try {
      final response = await http
          .get(Uri.parse(channelsUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final channels = _parseM3u(response.body);
        if (channels.isNotEmpty) {
          return channels;
        }
        throw Exception('Parsed M3U returned no channels');
      }
      throw Exception('Failed to load channels (HTTP ${response.statusCode})');
    } catch (_) {
      return _loadChannelsFromAsset();
    }
  }

  static List<Channel> _parseM3u(String raw) {
    final lines = raw.split(RegExp(r'\r?\n'));
    final channels = <Channel>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (!line.startsWith('#EXTINF:')) continue;

      final info = line.substring(8).trim();
      final commaIndex = info.lastIndexOf(',');
      final metadata = commaIndex >= 0 ? info.substring(0, commaIndex) : info;
      final title = commaIndex >= 0 ? info.substring(commaIndex + 1).trim() : '';

      final attrs = <String, String>{};
      for (final match in _attributeRegExp.allMatches(metadata)) {
        attrs[match.group(1)!] = match.group(2)!;
      }

      String name = title.isNotEmpty ? title : attrs['tvg-name'] ?? attrs['group-title'] ?? 'Unknown';
      final logo = attrs['tvg-logo'] ?? '';
      final category = attrs['group-title'];

      // Find the stream URL on the next non-empty, non-comment line.
      String? url;
      for (var j = i + 1; j < lines.length; j++) {
        final candidate = lines[j].trim();
        if (candidate.isEmpty || candidate.startsWith('#')) continue;
        url = candidate;
        break;
      }
      if (url == null || url.isEmpty) continue;

      channels.add(Channel(name: name, logo: logo, url: url, category: category));
    }

    return channels;
  }

  static Future<List<Channel>> _loadChannelsFromAsset() async {
    final jsonString = await rootBundle.loadString('channels.json');
    final List<dynamic> data = json.decode(jsonString);
    return data.map((e) => Channel.fromJson(e)).toList();
  }
}
