import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/domain/user_model.dart';

final profileProvider = Provider<UserModel?>((ref) => ref.watch(authProvider).user);
