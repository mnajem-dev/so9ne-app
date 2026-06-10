import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dcyuxosxbxlsyhbabgpt.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjeXV4b3N4Ynhsc3loYmFiZ3B0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwNTQ4NzksImV4cCI6MjA5NjYzMDg3OX0.iVpJoI7VwjhQuFhgX45lAwUJsCOHgViKp1Lk3AXaRvI',
  );

  runApp(const ProviderScope(child: So9neApp()));
}

class So9neApp extends StatelessWidget {
  const So9neApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'So9ne Fashion Marketplace',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
