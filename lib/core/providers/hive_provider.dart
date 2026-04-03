import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/hive_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});
