import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/quran_models.dart';
import '../services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  QuranProvider() {
    _initAudioListeners();
  }

  void _initAudioListeners() {
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && _selectedSurah != null && _playingSurahNumber == _selectedSurah?.number) {
        if (index < _selectedSurah!.ayahs.length) {
          _currentPlayingAyah = _selectedSurah!.ayahs[index].numberInSurah;
          notifyListeners();
        }
      }
    });

    _audioPlayer.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _currentPlayingAyah = null;
        notifyListeners();
      }
    });
  }


  // State for all Surahs (Full Quran)
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Download state tracking
  Set<int> _downloadedSurahs = {};
  Set<int> _downloadingSurahs = {};

  List<Surah> get filteredSurahs => _filteredSurahs;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Set<int> get downloadedSurahs => _downloadedSurahs;
  Set<int> get downloadingSurahs => _downloadingSurahs;

  // State for Single Surah Reading
  Surah? _selectedSurah;
  bool _isSurahLoading = false;
  String _surahErrorMessage = '';
  double _fontSize = 24.0; // default font size

  // Audio Playback State
  int? _currentPlayingAyah;
  bool _isPlaying = false;
  int? _playingSurahNumber;

  // Last Read State
  Map<String, dynamic>? _lastRead;

  Surah? get selectedSurah => _selectedSurah;
  bool get isSurahLoading => _isSurahLoading;
  String get surahErrorMessage => _surahErrorMessage;
  double get fontSize => _fontSize;
  Map<String, dynamic>? get lastRead => _lastRead;
  int? get currentPlayingAyah => _currentPlayingAyah;
  bool get isPlaying => _isPlaying;

  // Initialize and load full Quran from cache or API
  Future<void> loadFullQuran() async {
    if (_allSurahs.isNotEmpty) return; // Already loaded

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _allSurahs = await _quranService.fetchFullQuran();
      _filteredSurahs = List.from(_allSurahs);
      await initDownloadedSurahs();
      await loadLastRead();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check which Surahs are downloaded
  Future<void> initDownloadedSurahs() async {
    _downloadedSurahs.clear();
    for (int i = 1; i <= 114; i++) {
        if (await _quranService.isSurahDownloaded(i)) {
          _downloadedSurahs.add(i);
        }
    }
    notifyListeners();
  }

  // Last read logic
  Future<void> loadLastRead() async {
    _lastRead = await _quranService.getLastRead();
    notifyListeners();
  }

  Future<void> saveLastRead(int surahNumber, String surahName, int ayahNumber) async {
    await _quranService.saveLastRead(surahNumber, surahName, ayahNumber);
    _lastRead = {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
    };
    notifyListeners();
  }

  Future<bool> hasSeenSurahTutorial() async {
    return await _quranService.hasSeenSurahTutorial();
  }

  Future<void> setHasSeenSurahTutorial() async {
    await _quranService.setHasSeenSurahTutorial();
  }

  // Download a Surah explicitly
  Future<void> downloadSurah(int number) async {
    if (_downloadedSurahs.contains(number)) return;
    
    _downloadingSurahs.add(number);
    notifyListeners();
    
    try {
      await _quranService.fetchSurah(number);
      _downloadedSurahs.add(number);
    } catch (e) {
      debugPrint('Error downloading Surah $number: $e');
    } finally {
      _downloadingSurahs.remove(number);
      notifyListeners();
    }
  }

  // Filter surahs based on user search query
  void searchSurahs(String query) {
    if (query.isEmpty) {
      _filteredSurahs = List.from(_allSurahs);
    } else {
      _filteredSurahs = _allSurahs
          .where((surah) =>
              surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
              surah.name.contains(query) ||
              surah.englishNameTranslation.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Fetch a specific Surah
  Future<void> loadSurah(int number) async {
    _isSurahLoading = true;
    _surahErrorMessage = '';
    _selectedSurah = null;
    notifyListeners();

    try {
      _selectedSurah = await _quranService.fetchSurah(number);
    } catch (e) {
      _surahErrorMessage = e.toString();
    } finally {
      _isSurahLoading = false;
      notifyListeners();
    }
  }

  // Clear selected surah when leaving screen
  void clearSelectedSurah() {
    stopAudio();
    _selectedSurah = null;
    notifyListeners();
  }

  // --- Audio Playback Methods ---

  Future<void> playSurah(Surah surah) async {
    try {
      _playingSurahNumber = surah.number;
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: surah.ayahs.map((ayah) {
          return AudioSource.uri(Uri.parse(ayah.audio ?? ''));
        }).toList(),
      );
      await _audioPlayer.setAudioSource(playlist, initialIndex: 0, initialPosition: Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing surah: $e");
    }
  }

  Future<void> playAyah(Ayah ayah, Surah surah) async {
    try {
      _playingSurahNumber = surah.number;
      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: surah.ayahs.map((a) {
          return AudioSource.uri(Uri.parse(a.audio ?? ''));
        }).toList(),
      );
      final index = surah.ayahs.indexOf(ayah);
      await _audioPlayer.setAudioSource(playlist, initialIndex: index, initialPosition: Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing ayah: $e");
    }
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    _currentPlayingAyah = null;
    _playingSurahNumber = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Adjust font size
  void increaseFontSize() {
    if (_fontSize < 50.0) {
      _fontSize += 2.0;
      notifyListeners();
    }
  }

  void decreaseFontSize() {
    if (_fontSize > 14.0) {
      _fontSize -= 2.0;
      notifyListeners();
    }
  }
}
