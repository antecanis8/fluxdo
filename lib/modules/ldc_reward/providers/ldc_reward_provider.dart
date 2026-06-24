import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import '../../../l10n/s.dart';
import '../models/reward_request.dart';
import '../models/reward_result.dart';
import '../services/ldc_reward_service.dart';

/// LDC 打赏凭证模型
class LdcRewardCredentials {
  final String clientId;
  final String clientSecret;

  const LdcRewardCredentials({
    required this.clientId,
    required this.clientSecret,
  });

  bool get isValid => clientId.isNotEmpty && clientSecret.isNotEmpty;
}

/// 凭证管理 Provider
final ldcRewardCredentialsProvider =
    AsyncNotifierProvider<LdcRewardCredentialsNotifier, LdcRewardCredentials?>(
        LdcRewardCredentialsNotifier.new);

class LdcRewardCredentialsNotifier extends AsyncNotifier<LdcRewardCredentials?> {
  static const String _clientIdKey = 'ldc_reward_client_id';
  static const String _clientSecretKey = 'ldc_reward_client_secret';

  @override
  Future<LdcRewardCredentials?> build() async {
    if (!AppConstants.features.enableReward) return null;
    return _load();
  }

  Future<LdcRewardCredentials?> _load() async {
    if (!AppConstants.features.enableReward) return null;
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString(_clientIdKey);
    final clientSecret = prefs.getString(_clientSecretKey);
    if (clientId != null && clientSecret != null && clientId.isNotEmpty && clientSecret.isNotEmpty) {
      return LdcRewardCredentials(clientId: clientId, clientSecret: clientSecret);
    }
    return null;
  }

  /// 保存凭证
  Future<void> save(String clientId, String clientSecret) async {
    if (!AppConstants.features.enableReward) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientIdKey, clientId);
    await prefs.setString(_clientSecretKey, clientSecret);
    state = AsyncData(
      LdcRewardCredentials(clientId: clientId, clientSecret: clientSecret),
    );
  }

  /// 清除凭证
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientIdKey);
    await prefs.remove(_clientSecretKey);
    state = const AsyncData(null);
  }
}

/// 打赏防重复管理
/// 同一 topicId_postId_userId 在 2 分钟内不可重复打赏
class _RewardCooldown {
  static final Map<String, DateTime> _pending = {};
  static const _cooldown = Duration(minutes: 2);

  static String _key(int topicId, int postId, int userId) =>
      '${topicId}_${postId}_$userId';

  /// 检查是否在冷却期内，返回剩余秒数；不在冷却期返回 null
  static int? check(int topicId, int postId, int userId) {
    final key = _key(topicId, postId, userId);
    final expireAt = _pending[key];
    if (expireAt == null) return null;
    final remaining = expireAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      _pending.remove(key);
      return null;
    }
    return remaining;
  }

  static void mark(int topicId, int postId, int userId) {
    _pending[_key(topicId, postId, userId)] = DateTime.now().add(_cooldown);
  }
}

/// 检查打赏冷却期，返回剩余秒数；不在冷却期返回 null
int? checkRewardCooldown({
  required int topicId,
  required int postId,
  required int userId,
}) => _RewardCooldown.check(topicId, postId, userId);

/// 执行打赏
Future<LdcRewardResult> executeReward({
  required LdcRewardCredentials credentials,
  required int userId,
  required String username,
  required double amount,
  required int topicId,
  required int postId,
  String? remark,
}) async {
  if (!AppConstants.features.enableReward) {
    return const LdcRewardResult(
      success: false,
      errorMsg: 'Reward is disabled for this site.',
    );
  }
  // 防重复检查
  final remaining = _RewardCooldown.check(topicId, postId, userId);
  if (remaining != null) {
    return LdcRewardResult.error(S.current.reward_duplicateWarning(remaining));
  }

  final service = LdcRewardService(
    clientId: credentials.clientId,
    clientSecret: credentials.clientSecret,
  );

  final request = LdcRewardRequest(
    userId: userId,
    username: username,
    amount: amount,
    outTradeNo: LdcRewardRequest.generateTradeNo(topicId, postId),
    remark: remark,
  );

  final result = await service.distribute(request);

  // 成功后标记冷却
  if (result.success) {
    _RewardCooldown.mark(topicId, postId, userId);
  }

  return result;
}
