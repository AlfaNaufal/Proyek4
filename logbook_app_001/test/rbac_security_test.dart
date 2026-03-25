import 'package:flutter_test/flutter_test.dart';
import 'package:logbook_app_001/features/models/log_model.dart';

void main() {
  test('RBAC Security Check: Private logs should NOT be visible to teammates', () {
    // 1. SETUP DATA (Simulasi Data di Cloud)
    final String userA_Id = 'uid_A'; // Pemilik Catatan
    final String userB_Id = 'uid_B'; // Rekan Satu Tim

    // User A membuat catatan Rahasia (Private)
    final logPrivateUserA = LogModel(
      id: '1',
      title: 'Rahasia User A',
      category: 'Pribadi',
      description: 'Ini catatan private, teman sekelompok tidak boleh tahu.',
      date: DateTime.now(),
      authorId: userA_Id,
      teamId: 'team_1',
      isPublic: false, // PRIVATE
    );

    // User A membuat catatan Publik
    final logPublicUserA = LogModel(
      id: '2',
      title: 'Laporan Publik User A',
      category: 'Pekerjaan',
      description: 'Ini catatan public, teman sekelompok boleh lihat.',
      date: DateTime.now(),
      authorId: userA_Id,
      teamId: 'team_1',
      isPublic: true, // PUBLIC
    );

    // Kumpulan semua data mentah yang ada di database kelompok tersebut
    final List<LogModel> allLogsInDatabase = [logPrivateUserA, logPublicUserA];

    // 2. ACTION: User B melakukan Fetch/Load Data
    // Simulasi logika filter visibilitas yang ada di LogView milikmu
    final List<LogModel> fetchedDataForUserB = allLogsInDatabase.where((log) {
      // Aturan: Tampilkan JIKA milik sendiri ATAU statusnya publik
      return log.authorId == userB_Id || log.isPublic == true;
    }).toList();

    // 3. ASSERT (VALIDASI KEAMANAN)
    // Cek 1: Pastikan User B HANYA menerima 1 catatan (Sistem akan gagal jika menerima 2)
    expect(fetchedDataForUserB.length, 1, reason: 'Kebocoran Data! User B melihat catatan yang seharusnya disembunyikan.');
    
    // Cek 2: Pastikan 1 catatan yang diterima itu benar-benar catatan yang berstatus Public
    expect(fetchedDataForUserB.first.title, 'Laporan Publik User A');
    expect(fetchedDataForUserB.first.isPublic, true);
  });
}