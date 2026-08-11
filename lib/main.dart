import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:audio_service/audio_service.dart';
import 'homepage.dart';
import 'music_library.dart';
import 'providers.dart';
import 'collapsed_bar_overlay.dart';
import 'search_results_view.dart';
import 'music_audio_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();

  final audioHandler = await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_player.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [audioHandlerProvider.overrideWithValue(audioHandler)],
      child: LiquidGlassWidgets.wrap(child: const MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final isPillCollapsed = ref.watch(isPillCollapsedProvider);
    final scrollController = ref.watch(scrollControllerProvider);
    final navigatorKey = ref.watch(navigatorKeyProvider);

    final pages = [
      Homepage(scrollController: scrollController),
      MusicLibrary(scrollController: scrollController),
    ];

    final hideRealBar = isPillCollapsed && !isSearching;

    return CupertinoApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const CollapsedBarOverlay(),
          ],
        );
      },
      home: GlassScaffold(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0A2E),
                Color(0xFF3A1C71),
                Color(0xFFD76D77),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis != Axis.vertical) return false;
              final shouldCollapse = notification.metrics.pixels > 50;
              ref.read(isPillCollapsedProvider.notifier).setCollapsed(shouldCollapse);
              return false;
            },
            child: isSearching ? const SearchResultsView() : pages[selectedIndex],
          ),
        ),
        bottomBar: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: hideRealBar ? 0 : 1,
          child: IgnorePointer(
            ignoring: hideRealBar,
            child: GlassTabBar.searchable(
              settings: const LiquidGlassSettings(
                thickness: 20,
                glassColor: Color(0x1AFFFFFF),
              ),
              tabs: const [
                GlassTab(icon: Icon(CupertinoIcons.home)),
                GlassTab(icon: Icon(CupertinoIcons.music_albums)),
              ],
              selectedIndex: selectedIndex,
              onTabSelected: (i) {
                ref.read(selectedIndexProvider.notifier).select(i);
              },
              isSearchActive: isSearching,
              searchConfig: GlassSearchBarConfig(
                hintText: 'Search',
                autoFocusOnExpand: true,
                onSearchToggle: (isOpen) {
                  ref.read(isSearchingProvider.notifier).setSearching(isOpen);
                  if (!isOpen) {
                    ref.read(searchQueryProvider.notifier).setQuery('');
                  }
                },
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).setQuery(query);
                },
                collapsedLogoBuilder: (context) => Icon(
                  CupertinoIcons.home,
                  color: CupertinoColors.label.resolveFrom(context),
                ),
                collapsedTabWidth: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }
}