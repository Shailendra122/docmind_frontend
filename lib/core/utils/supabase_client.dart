import 'package:supabase_flutter/supabase_flutter.dart';

// Global shortcut — use anywhere in the app
// Instead of: Supabase.instance.client.from(...)
// Just write:  supabase.from(...)

final supabase = Supabase.instance.client;

// Quick access to current logged-in user
// Returns null if not logged in
final currentUser = Supabase.instance.client.auth.currentUser;