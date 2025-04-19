import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/persist_json.dart';
import '../models/uri_config.dart';

class UriConfigNotifier extends StateNotifier<UriConfig> {
  UriConfigNotifier(this.uri, [this.store])
      : storeKey = 'MediaViewer: uri:  $uri',
        super(const UriConfig()) {
    initialize();
  }
  final Uri uri;
  final PersistJson? store;
  final String storeKey;
  Future<void> initialize() async {
    if (store != null) {
      state = UriConfig.fromJson(
        await store!.loadJson(
          storeKey,
          const UriConfig().toJson(),
        ),
      );
    }
  }

  Future<void> update({
    int? quarterTurns,
    Duration? lastKnownPlayPosition,
  }) async {
    state = state.copyWith(
      quarterTurns: quarterTurns,
      lastKnownPlayPosition: lastKnownPlayPosition,
    );
    if (store != null) {
      await store!.saveJson(storeKey, state.toJson());
    }
  }
}

final uriConfigurationProvider =
    StateNotifierProvider.family<UriConfigNotifier, UriConfig, Uri>((ref, uri) {
  return UriConfigNotifier(uri);
});
