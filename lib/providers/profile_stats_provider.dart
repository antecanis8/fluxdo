import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../models/profile_stats_config.dart';
import 'theme_provider.dart'; // sharedPreferencesProvider

const String _configKey = 'profile_stats_config';

/// 统计卡片配置 Provider
class ProfileStatsConfigNotifier extends Notifier<ProfileStatsConfig> {
  Timer? _saveTimer;
  @override
  ProfileStatsConfig build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_configKey);
    if (jsonStr != null) {
      try {
        return _sanitize(ProfileStatsConfig.fromJsonString(jsonStr));
      } catch (_) {
        // 配置损坏，使用默认值
      }
    }
    return _sanitize(const ProfileStatsConfig());
  }

  void update(ProfileStatsConfig config) {
    final sanitized = _sanitize(config);
    state = sanitized;
    _save(sanitized);
  }

  void setLayoutMode(StatsLayoutMode mode) {
    update(state.copyWith(layoutMode: mode));
  }

  void setColumnsPerRow(int columns) {
    update(state.copyWith(columnsPerRow: columns));
  }

  void setDataSource(StatsDataSource source) {
    // 切换数据源时，自动移除不兼容的统计项
    final compatible = state.enabledStats
        .where((s) => isStatCompatible(s, source))
        .toList();
    update(state.copyWith(
      dataSource: source,
      enabledStats: compatible,
    ));
  }

  void setEnabledStats(List<ProfileStatType> stats) {
    update(state.copyWith(enabledStats: stats));
  }

  void addStat(ProfileStatType stat) {
    if (!state.enabledStats.contains(stat)) {
      update(state.copyWith(
        enabledStats: [...state.enabledStats, stat],
      ));
    }
  }

  void removeStat(ProfileStatType stat) {
    update(state.copyWith(
      enabledStats: state.enabledStats.where((s) => s != stat).toList(),
    ));
  }

  void reorderStats(int oldIndex, int newIndex) {
    final stats = List<ProfileStatType>.from(state.enabledStats);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = stats.removeAt(oldIndex);
    stats.insert(newIndex, item);
    update(state.copyWith(enabledStats: stats));
  }

  /// 防抖保存（300ms 内多次操作只写一次磁盘）
  void _save(ProfileStatsConfig config) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), () {
      final prefs = ref.read(sharedPreferencesProvider);
      prefs.setString(_configKey, config.toJsonString());
    });
  }

  ProfileStatsConfig _sanitize(ProfileStatsConfig config) {
    if (AppConstants.features.enableConnectStats) {
      return config;
    }

    return config.copyWith(
      dataSource: StatsDataSource.summary,
      enabledStats: config.enabledStats
          .where((stat) => isStatCompatible(stat, StatsDataSource.summary))
          .toList(),
    );
  }
}

final profileStatsConfigProvider =
    NotifierProvider<ProfileStatsConfigNotifier, ProfileStatsConfig>(
  ProfileStatsConfigNotifier.new,
);
