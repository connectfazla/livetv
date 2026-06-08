import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';

class ChannelService {
  // ───────────────────────────────────────────────────────────
  // 🔧 CHANGE THIS to wherever you host channels.json
  //    Editing that file on your server updates every user's app.
  // ───────────────────────────────────────────────────────────
  static const String channelsUrl = 'https://yourdomain.com/channels.json';

  static Future<List<Channel>> fetchChannels() async {
    final response = await http.get(Uri.parse(channelsUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Channel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load channels (HTTP ${response.statusCode})');
    }
  }
}
