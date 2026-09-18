import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';

/// Route names are constants so deep links, push payloads and tests never
/// depend on string literals scattered through the code.
abstract final class AppRoutes {
  static const home = '/';
  // Added in later stages:
  //   /sign-in, /callers, /callers/:id, /call/:callId, /wallet, /wallet/buy,
  //   /profile, /caller/onboarding, /settings/notifications
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
    ],
  );
});
