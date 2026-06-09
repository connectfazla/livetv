import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'about_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _future = ChannelService.fetchChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = ChannelService.fetchChannels();
    setState(() => _future = future);
    await future;
  }

  bool _matchesFilter(Channel channel) {
    final query = _filter.trim().toLowerCase();
    final matchesSearch = query.isEmpty ||
        channel.name.toLowerCase().contains(query) ||
        (channel.category?.toLowerCase().contains(query) ?? false);
    final matchesCategory =
        _selectedCategory == 'All' || channel.category == _selectedCategory;
    return matchesSearch && matchesCategory;
  }

  void _buildCategories(List<Channel> channels) {
    final cats = channels
        .map((c) => c.category ?? 'Other')
        .toSet()
        .toList()
      ..sort();
    _categories = ['All', ...cats];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: const Color(0xFF00E676),
                backgroundColor: const Color(0xFF0E1319),
                child: FutureBuilder<List<Channel>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _LoadingView();
                    }
                    if (snapshot.hasError) {
                      return _ErrorView(
                          message: '${snapshot.error}', onRetry: _refresh);
                    }
                    final channels = snapshot.data ?? [];
                    if (_categories.length <= 1) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _buildCategories(channels));
                      });
                    }
                    final filtered = channels.where(_matchesFilter).toList();

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildCategoryChips()),
                        if (filtered.isEmpty)
                          SliverFillRemaining(
                            child: _EmptyView(query: _filter),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _ChannelCard(
                                  channel: filtered[index],
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PlayerScreen(channel: filtered[index]),
                                    ),
                                  ),
                                ),
                                childCount: filtered.length,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    MediaQuery.of(context).size.width > 900
                                        ? 4
                                        : MediaQuery.of(context).size.width > 650
                                            ? 3
                                            : 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LIVE SPORTS',
                      style: GoogleFonts.russoOne(
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const _LiveBadge(),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Watch live matches worldwide',
                  style: TextStyle(color: Color(0xFF4A6070), fontSize: 13),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFF0E1319),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFF1A2430)),
              ),
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                'assets/icons/tv-svgrepo-com.svg',
                colorFilter:
                    const ColorFilter.mode(Color(0xFF5A7A8A), BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E1319),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1A2430)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _filter = v),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded,
                color: Color(0xFF3A5060), size: 22),
            hintText: 'Search channels, teams, leagues...',
            hintStyle: const TextStyle(color: Color(0xFF3A5060), fontSize: 14),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _filter.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF4A6070), size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _filter = '');
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    if (_categories.length <= 1) return const SizedBox(height: 12);
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final selected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF00E676)
                    : const Color(0xFF0E1319),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF00E676)
                      : const Color(0xFF1A2430),
                ),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF060A08)
                      : const Color(0xFF5A7A8A),
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────── Live Badge ────────────────────

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _opacity = Tween(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x1FFF3B3B),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0x40FF3B3B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _opacity,
            builder: (_, __) => Opacity(
              opacity: _opacity.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: Color(0xFFFF3B3B), shape: BoxShape.circle),
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFFFF3B3B),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────── Channel Card ──────────────────

class _ChannelCard extends StatefulWidget {
  final Channel channel;
  final VoidCallback onTap;
  const _ChannelCard({required this.channel, required this.onTap});

  @override
  State<_ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<_ChannelCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: _pressed ? 0.95 : 1.0,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D1520), Color(0xFF0A1018)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _pressed
                  ? const Color(0xFF00E676).withValues(alpha: 0.45)
                  : const Color(0xFF182330),
            ),
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: 0.12),
                      blurRadius: 18,
                      spreadRadius: 2,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo area
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFF08111A),
                        child: widget.channel.logo.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(18),
                                child: Image.network(
                                  widget.channel.logo,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.live_tv_rounded,
                                    color: Color(0xFF243040),
                                    size: 40,
                                  ),
                                ),
                              )
                            : const Icon(Icons.live_tv_rounded,
                                color: Color(0xFF243040), size: 40),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 28,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xFF0A1018)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      // Play overlay on press
                      Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _pressed ? 1.0 : 0.0,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.black, size: 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info area
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.channel.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            if (widget.channel.category != null)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B1522),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFF1A2D3D)),
                                  ),
                                  child: Text(
                                    widget.channel.category!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF4A6A7A),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF00E676)
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(Icons.play_arrow_rounded,
                                  color: Color(0xFF00E676), size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────── Empty State ───────────────────

class _EmptyView extends StatelessWidget {
  final String query;
  const _EmptyView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF0E1319),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1A2430)),
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: Color(0xFF2A4050), size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'No channels found',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'No results for "$query".\nTry a different keyword.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF4A6070), fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Error State ───────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF120808),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3D1515)),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: Color(0xFFFF3B3B), size: 40),
            ),
            const SizedBox(height: 22),
            const Text(
              'Connection failed',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF4A6070), fontSize: 13, height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────── Loading Skeleton ──────────────

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth > 0
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      if (width <= 0) {
        return const SizedBox.shrink();
      }

      final cols = width > 900 ? 4 : width > 650 ? 3 : 2;
      final cardW = (width - 32 - (cols - 1) * 12) / cols;
      final safeCardW = cardW > 0 ? cardW : 120.0;

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ShimmerBox(height: 28, width: 180, radius: 8),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                8,
                (_) => _ShimmerBox(
                    height: safeCardW / 0.82, width: safeCardW, radius: 20),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double width;
  final double radius;
  const _ShimmerBox(
      {required this.height, required this.width, this.radius = 8});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeWidth = widget.width.isFinite && widget.width > 0
        ? widget.width
        : 120.0;
    final safeHeight = widget.height.isFinite && widget.height > 0
        ? widget.height
        : 120.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: safeWidth,
        height: safeHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(colors: [
            Color.lerp(const Color(0xFF0E1319), const Color(0xFF18242F),
                _anim.value)!,
            Color.lerp(const Color(0xFF18242F), const Color(0xFF0E1319),
                _anim.value)!,
          ]),
        ),
      ),
    );
  }
}
