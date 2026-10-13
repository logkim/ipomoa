import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/ipo_tables.dart';

export 'tables/ipo_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    IpoItems,
    IpoRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'ipo_app'));

  /// 앱 기본 DB 파일(`ipo_app`)을 연다.
  AppDatabase.open() : super(driftDatabase(name: 'ipo_app'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
