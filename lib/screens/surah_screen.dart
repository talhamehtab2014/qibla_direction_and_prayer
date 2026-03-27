import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/quran_provider.dart';

class SurahScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  late QuranProvider _quranProvider;

  @override
  void initState() {
    super.initState();
    _quranProvider = context.read<QuranProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quranProvider.loadSurah(widget.surahNumber);
      _checkAndShowTutorial();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    final provider = context.read<QuranProvider>();
    final hasSeen = await provider.hasSeenSurahTutorial();
    if (!hasSeen && mounted) {
      _showTutorialDialog();
      provider.setHasSeenSurahTutorial();
    }
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Welcome to Surah Reading',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18.sp),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.bookmark, color: Theme.of(context).primaryColor, size: 28.sp),
              title: Text('Save Last Read', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Tap the bookmark icon on any Ayah to save it as your "Last Read". It will appear on the main Quran screen for quick resume!',
                style: GoogleFonts.poppins(fontSize: 12.sp),
              ),
            ),
            SizedBox(height: 12.h),
            ListTile(
              leading: Icon(Icons.share, color: Theme.of(context).primaryColor, size: 28.sp),
              title: Text('Share Ayah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Tap the share icon to instantly send the Arabic text and reference to your friends or social media.',
                style: GoogleFonts.poppins(fontSize: 12.sp),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Synchronously stop audio and clear data when leaving
    _quranProvider.clearSelectedSurah();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.surahName,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Consumer<QuranProvider>(
            builder: (context, provider, child) {
              final surah = provider.selectedSurah;
              final bool isPlayingSurah = provider.isPlaying && provider.currentPlayingAyah != null;
              
              return IconButton(
                icon: Icon(
                  isPlayingSurah ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  size: 24.sp,
                ),
                onPressed: () {
                  if (surah == null) return;
                  if (provider.isPlaying) {
                    provider.pauseAudio();
                  } else {
                    provider.playSurah(surah);
                  }
                },
                tooltip: isPlayingSurah ? 'Pause Surah' : 'Play Surah',
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.text_decrease, size: 20.sp),
            onPressed: () => context.read<QuranProvider>().decreaseFontSize(),
            tooltip: 'Decrease Font Size',
          ),
          IconButton(
            icon: Icon(Icons.text_increase, size: 20.sp),
            onPressed: () => context.read<QuranProvider>().increaseFontSize(),
            tooltip: 'Increase Font Size',
          ),
          SizedBox(width: 4.w),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<QuranProvider>(
            builder: (context, provider, child) {
              if (provider.isSurahLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.surahErrorMessage.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      'Error: \${provider.surahErrorMessage}',
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 16.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final surah = provider.selectedSurah;
              if (surah == null) {
                return Center(
                  child: Text(
                    'Surah data not found',
                    style: GoogleFonts.poppins(fontSize: 16.sp),
                  ),
                );
              }

              return Column(
                children: [
                  _buildBismillahHeader(surah.name),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        bottom: 24.h,
                        top: 8.h,
                      ),
                      itemCount: surah.ayahs.length,
                      itemBuilder: (context, index) {
                        final ayah = surah.ayahs[index];
                        final bool isLastRead = provider.lastRead != null &&
                            provider.lastRead!['surahNumber'] == surah.number &&
                            provider.lastRead!['ayahNumber'] == ayah.numberInSurah;
                        
                        final bool isPlayingAyah = provider.isPlaying && provider.currentPlayingAyah == ayah.numberInSurah;
                        final bool isCurrentAyah = provider.currentPlayingAyah == ayah.numberInSurah;

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isCurrentAyah 
                                ? Theme.of(context).primaryColor.withOpacity(0.15) 
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: isCurrentAyah 
                                ? Border.all(color: Theme.of(context).primaryColor, width: 1.5)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${ayah.numberInSurah}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isPlayingAyah ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                        ),
                                        color: isPlayingAyah ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.6),
                                        iconSize: 26.sp,
                                        onPressed: () {
                                          if (isPlayingAyah) {
                                            provider.pauseAudio();
                                          } else {
                                            provider.playAyah(ayah, surah);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share_outlined),
                                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                                        iconSize: 22.sp,
                                        onPressed: () {
                                          Share.share('${ayah.text}\n\n[Quran ${surah.englishName} ${surah.number}:${ayah.numberInSurah}]');
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(isLastRead ? Icons.bookmark : Icons.bookmark_border),
                                        color: isLastRead ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withOpacity(0.7),
                                        iconSize: 22.sp,
                                        onPressed: () {
                                          provider.saveLastRead(surah.number, surah.englishName, ayah.numberInSurah);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Saved as Last Read',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              behavior: SnackBarBehavior.floating,
                                              backgroundColor: Theme.of(context).primaryColor,
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                ayah.text,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.amiri(
                                  fontSize: provider.fontSize,
                                  height: 2.0, // generous line height for Arabic
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBismillahHeader(String surahArabicName) {
    // We only show Bismillah if it's not Al-Fatihah, but for simplicity we can show a nice hero card here.
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            surahArabicName,
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 1.h,
            width: 150.w,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
            style: GoogleFonts.amiri(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
