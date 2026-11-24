import 'package:flutter_test/flutter_test.dart';
import 'package:dosen_modul_10/modul_10/data/layanan_ai_terbatas.dart';
import 'package:dosen_modul_10/modul_10/presentation/view_model_obrolan.dart';

void main() {
  group('LayananAiTerbatas', () {
    test('Jawaban lengkap dan memiliki beberapa potongan', () async {
      final layanan = LayananAiTerbatas();
      // ViewModel menggunakan method 'kirim' yang mengembalikan Stream
      final stream = layanan.kirim('Apa itu Flutter?');
      final potongan = await stream.toList();

      expect(potongan.length, greaterThan(1));
      expect(potongan.join().trim(), isNotEmpty);
    });

    test('Layanan dapat digunakan oleh ViewModelObrolan tanpa ubah ViewModel',
        () async {
      // 1. Perbaiki nama kelas menjadi ViewModelObrolan
      // 2. Perbaiki parameter menjadi 'layanan'
      final viewModel = ViewModelObrolan(layanan: LayananAiTerbatas());
      
      // 3. Perbaiki pemanggilan method menjadi 'kirim' dan await langsung
      await viewModel.kirim('Halo');
      
      // Cek apakah pesan sudah masuk ke dalam list pesan di ViewModel
      expect(viewModel.pesan, isNotEmpty);
      expect(viewModel.pesan.last.isi, isNotEmpty);
    });
  });
}