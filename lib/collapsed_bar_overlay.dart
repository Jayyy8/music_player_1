import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'providers.dart';
import 'now_playing_page.dart';

class CollapsedBarOverlay extends ConsumerWidget {
  const CollapsedBarOverlay({super.key});

  static const double circleSize = 56;
  static const double edgeMargin = 16;
  static const double gap = 10;
  static const double modalLiftAmount = 300;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(isPillCollapsedProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final navigatorKey = ref.watch(navigatorKeyProvider);
    final isNowPlayingOpen = ref.watch(isNowPlayingOpenProvider);
    final isModalOpen = ref.watch(isModalOpenProvider);
    final song = audioState.currentSong;

    final screenWidth = MediaQuery.of(context).size.width;
    final hideEverything = isSearching || isNowPlayingOpen;
    final modalLift = isModalOpen ? modalLiftAmount : 0.0;

    return IgnorePointer(
      ignoring: hideEverything,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: hideEverything ? 0 : 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              left: edgeMargin,
              bottom: 34,
              width: circleSize,
              height: circleSize,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: isCollapsed ? 1 : 0,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  shape: const LiquidOval(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref.read(selectedIndexProvider.notifier).select(0);
                      final controller = ref.read(scrollControllerProvider);
                      if (controller.hasClients) {
                        controller.animateTo(
                          0,
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    child: Icon(
                      CupertinoIcons.home,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              left: screenWidth - edgeMargin - circleSize,
              bottom: 34,
              width: circleSize,
              height: circleSize,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: isCollapsed ? 1 : 0,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  shape: const LiquidOval(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        ref.read(isSearchingProvider.notifier).setSearching(true),
                    child: Icon(
                      CupertinoIcons.search,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              left: isCollapsed ? edgeMargin + circleSize + gap : edgeMargin,
              bottom: (isCollapsed ? 34 : 116) + modalLift,
              width: isCollapsed
                  ? screenWidth - (edgeMargin + circleSize + gap) * 2
                  : screenWidth - edgeMargin * 2,
              height: isCollapsed ? circleSize : 64,
              child: GlassGroupedSection(
                margin: EdgeInsets.zero,
                shape: const LiquidRoundedSuperellipse(borderRadius: 20),
                children: [
                  GlassListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: song != null
                          ? () =>
                          ref.read(audioPlayerProvider.notifier).togglePlayPause()
                          : null,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: song != null
                              ? const LinearGradient(colors: [
                            CupertinoColors.systemPink,
                            CupertinoColors.systemPurple,
                          ])
                              : null,
                          color: song == null
                              ? CupertinoColors.white.withValues(alpha: 0.15)
                              : null,
                        ),
                        child: Icon(
                          song != null
                              ? (audioState.isPlaying
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill)
                              : CupertinoIcons.music_note,
                          color: CupertinoColors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    title: Text(
                      song?.title ?? 'Not Playing',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: song != null
                        ? Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                        : null,
                    onTap: song != null
                        ? () async {
                      ref.read(isNowPlayingOpenProvider.notifier).setOpen(true);
                      await navigatorKey.currentState
                          ?.push(nowPlayingPageRoute());
                      ref.read(isNowPlayingOpenProvider.notifier).setOpen(false);
                    }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}