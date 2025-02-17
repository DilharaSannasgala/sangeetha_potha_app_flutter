import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sangeetha_potha_app_flutter/utils/app_components.dart';
import 'package:sangeetha_potha_app_flutter/services/manage_favorite.dart';
import '../widgets/song_tile.dart';

class SongScreen extends StatefulWidget {
  final String avatarUrl;
  final String title;
  final String subtitle;
  final String lyrics;

  const SongScreen({
    super.key,
    required this.avatarUrl,
    required this.title,
    required this.subtitle,
    required this.lyrics,
  });

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  final ValueNotifier<double> _fontSize = ValueNotifier(16.0);
  final ValueNotifier<bool> _showAdjustableBar = ValueNotifier(false);
  late final String _cleanedLyrics;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _cleanedLyrics = _cleanLyrics(widget.lyrics);
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await FavoritesManager.isFavorite(widget.title);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  @override
  void dispose() {
    _fontSize.dispose();
    _showAdjustableBar.dispose();
    super.dispose();
  }

  String _cleanLyrics(String lyrics) {
    return lyrics
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\t', '')
        .replaceAll('"', '')
        .replaceAll(',', '\n')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildAppBarSection(),
                const SizedBox(height: 8), // Reduced spacing
                _buildSongTileSection(),
                Expanded(
                  child: _buildLyricsSection(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.23),
              BlendMode.dstATop,
            ),
            child: Image.asset(
              AppComponents.background,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showAdjustableBar,
      builder: (context, showAdjustableBar, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: showAdjustableBar
              ? _buildAdjustableBar()
              : _buildDefaultAppBar(),
        );
      },
    );
  }

  Widget _buildDefaultAppBar() {
    return AppBar(
      key: const ValueKey('DefaultAppBar'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0), // Reduced padding
        child: SvgPicture.asset(
          AppComponents.logo,
          height: 40,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.text_fields, color: Colors.white),
          onPressed: () => _showAdjustableBar.value = true,
        ),
      ],
    );
  }

  Widget _buildAdjustableBar() {
    return Container(
      key: const ValueKey('AdjustableBar'),
      color: Colors.black.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
      child: ValueListenableBuilder<double>(
        valueListenable: _fontSize,
        builder: (context, fontSize, _) {
          return Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => _showAdjustableBar.value = false,
              ),
              Expanded(
                child: Slider(
                  value: fontSize,
                  min: 12.0,
                  max: 32.0,
                  divisions: 20,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.5),
                  onChanged: (value) => _fontSize.value = value,
                ),
              ),
              Text(
                fontSize.toStringAsFixed(0),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSongTileSection() {
    return SongTile(
      avatarUrl: widget.avatarUrl,
      title: widget.title,
      subtitle: widget.subtitle,
      isFav: _isFavorite,
      onFavoriteToggle: (isFavorited) async {
        await FavoritesManager.setFavorite(widget.title, isFavorited);
        if (mounted) {
          setState(() {
            _isFavorite = isFavorited;
          });
        }
      },
    );
  }

  Widget _buildLyricsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  'Lyrics',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: ValueListenableBuilder<double>(
              valueListenable: _fontSize,
              builder: (context, fontSize, _) {
                return SingleChildScrollView(
                  child: Text(
                    _cleanedLyrics,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: fontSize,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}