import 'package:flutter_test/flutter_test.dart';
import 'package:livetv/models/channel.dart';

void main() {
  test('Channel JSON parsing test', () {
    final json = {
      'name': 'Test Channel',
      'logo': 'https://example.com/logo.png',
      'url': 'https://example.com/stream.m3u8',
      'category': 'Entertainment',
    };
    final channel = Channel.fromJson(json);
    expect(channel.name, 'Test Channel');
    expect(channel.logo, 'https://example.com/logo.png');
    expect(channel.url, 'https://example.com/stream.m3u8');
    expect(channel.category, 'Entertainment');
  });
}

