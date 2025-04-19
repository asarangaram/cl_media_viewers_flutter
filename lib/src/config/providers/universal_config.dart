import 'package:cl_media_viewers_flutter/src/config/models/universal_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/persist_json.dart';

class UniversalConfigNotifier extends StateNotifier<UniversalConfiguration> {
  UniversalConfigNotifier([this.store])
      : super(const UniversalConfiguration()) {
    initialize();
  }
  final PersistJson? store;
  final String storeKey = 'MediaViewer: UniversalConfiguration';
  Future<void> initialize() async {
    if (store != null) {
      state = UniversalConfiguration.fromJson(
        await store!.loadJson(
          storeKey,
          const UniversalConfiguration().toJson(),
        ),
      );
    }
  }

  Future<void> update({
    bool? isAudioMuted,
    double? lastKnownVolume,
  }) async {
    final volume =
        lastKnownVolume != null && lastKnownVolume <= 0 ? 1.0 : lastKnownVolume;

    state = state.copyWith(
      isAudioMuted: isAudioMuted,
      lastKnownVolume: volume,
    );
    if (store != null) {
      await store!.saveJson(storeKey, state.toJson());
    }
  }
}

final universalConfigurationProvider =
    StateNotifierProvider<UniversalConfigNotifier, UniversalConfiguration>(
        (ref) {
  return UniversalConfigNotifier();
});
