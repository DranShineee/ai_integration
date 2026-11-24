import 'dart:async';
import '../domain/kontrak_layanan_ai.dart'; 

/// Implementasi [LayananAi] yang membatasi jumlah permintaan,
/// menyaring data sensitif, dan menolak topik di luar cakupan.
class LayananAiTerbatas implements LayananAi {
  @override
  String get nama => 'Layanan AI Terbatas';

  static const int _maxPermintaanPerMenit = 5;
  final List<DateTime> _waktuPermintaan = [];

  static const List<String> _topikDiluarCakupan = [
    'politik',
    'agama',
    'kekerasan',
    'ramalan',
  ];

  /// Mengirim pertanyaan dan mengembalikan aliran jawaban (stream).
  /// Akan mengembalikan pesan penolakan jika kuota habis atau di luar cakupan.
  @override
  Stream<String> kirim(String pertanyaan) async* {
    if (!_bolehMeminta()) {
      yield 'Maaf, kuota permintaan Anda telah habis. Silakan coba lagi nanti.';
      return;
    }

    if (_diLuarCakupan(pertanyaan)) {
      yield 'Maaf, pertanyaan Anda berada di luar cakupan layanan ini. '
          'Silakan ajukan pertanyaan seputar topik yang tersedia.';
      return;
    }

    final pesanTersaring = _saringPesan(pertanyaan);
    if (pesanTersaring != pertanyaan) {
      yield 'Pertanyaan Anda mengandung informasi sensitif dan telah disamarkan. ';
    }

    final jawaban = _buatJawaban(pesanTersaring);
    final potongan = jawaban.split(' ');
    for (final kata in potongan) {
      yield '$kata ';
      await Future.delayed(const Duration(milliseconds: 40));
    }

    _waktuPermintaan.add(DateTime.now());
  }

  /// Menutup layanan dan membebaskan sumber daya.
  @override
  void tutup() {
    // Tidak ada resource yang perlu ditutup
  }

  bool _bolehMeminta() {
    final sekarang = DateTime.now();
    _waktuPermintaan.removeWhere(
      (waktu) => sekarang.difference(waktu).inSeconds > 60,
    );
    return _waktuPermintaan.length < _maxPermintaanPerMenit;
  }

  bool _diLuarCakupan(String pertanyaan) {
    final lower = pertanyaan.toLowerCase();
    return _topikDiluarCakupan.any((topik) => lower.contains(topik));
  }

  String _saringPesan(String pesan) {
    var hasil = pesan.replaceAll(RegExp(r'[A-Za-z0-9]{32}'), '[API_KEY]');
    hasil = hasil.replaceAll(
      RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),
      '[EMAIL]',
    );
    return hasil;
  }

  String _buatJawaban(String pertanyaan) {
    return 'Ini adalah jawaban untuk: "$pertanyaan". '
        'Layanan AI terbatas ini hanya menyediakan informasi umum.';
  }
}