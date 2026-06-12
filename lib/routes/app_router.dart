import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/shop/collections_screen.dart';
import '../screens/shop/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/shop/order_history_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_inventory_screen.dart';
import '../screens/admin/admin_orders_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

String? _cachedUserRole;

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
  redirect: (context, state) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthRoute = state.matchedLocation == '/login';
    
    if (session == null) {
      _cachedUserRole = null;
      return isAuthRoute ? null : '/login';
    }
    
    if (_cachedUserRole == null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', session.user.id)
            .single();
        _cachedUserRole = response['role'] as String?;
      } catch (e) {
        debugPrint('Error fetching role: $e');
        _cachedUserRole = 'Client';
      }
    }
    
    final isAdmin = _cachedUserRole == 'Admin';
    final isAdminRoute = state.matchedLocation.startsWith('/admin');
    
    if (isAuthRoute) {
      return isAdmin ? '/admin' : '/';
    }
    
    if (isAdmin && state.matchedLocation == '/') {
      return '/admin';
    }
    
    if (!isAdmin && isAdminRoute) {
      return '/';
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const CollectionsScreen(),
      routes: [
        GoRoute(
          path: 'product/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return ProductDetailScreen(productId: id);
          },
        ),
        GoRoute(
          path: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: 'orders',
          builder: (context, state) => const OrderHistoryScreen(),
        ),
      ],
    ),
    // Admin routes
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'inventory',
          builder: (context, state) => const AdminInventoryScreen(),
        ),
        GoRoute(
          path: 'orders',
          builder: (context, state) => const AdminOrdersScreen(),
        ),
      ],
    ),
  ],
);
