import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ─── Brand Colors ──────────────────────────────────────
  static const primary = Color(0xFF7C6AF7);        // Purple (main brand)
  static const primaryLight = Color(0xFF9D95F9);   // Lighter purple
  static const primaryDark = Color(0xFF5B4EE8);    // Darker purple

  // ─── Background Colors (Dark Theme) ────────────────────
  static const bgDark = Color(0xFF0F0F10);         // Main background
  static const bgCard = Color(0xFF1A1A1F);         // Card background
  static const bgElevated = Color(0xFF222228);     // Elevated surfaces
  static const bgInput = Color(0xFF2A2A32);        // Input fields

  // ─── Text Colors ───────────────────────────────────────
  static const textPrimary = Color(0xFFF2F2F7);    // Main text
  static const textSecondary = Color(0xFF9898A5);  // Subtle text
  static const textHint = Color(0xFF606070);       // Placeholder text

  // ─── Border Colors ─────────────────────────────────────
  static const border = Color(0xFF2E2E38);         // Default border
  static const borderFocused = Color(0xFF7C6AF7);  // Focused border

  // ─── Status Colors ─────────────────────────────────────
  static const success = Color(0xFF34C759);        // Green
  static const warning = Color(0xFFFF9F0A);        // Orange
  static const error = Color(0xFFFF453A);          // Red
  static const info = Color(0xFF0A84FF);           // Blue

  // ─── Chat Bubble Colors ────────────────────────────────
  static const userBubble = Color(0xFF7C6AF7);     // User message
  static const aiBubble = Color(0xFF1A1A1F);       // AI message

  // ─── Gradient ──────────────────────────────────────────
  static const gradientPrimary = LinearGradient(
    colors: [Color(0xFF7C6AF7), Color(0xFF5B4EE8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientBackground = LinearGradient(
    colors: [Color(0xFF0F0F10), Color(0xFF16161D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Sidebar ───────────────────────────────────────────
  static const sidebarBg = Color(0xFF13131A);      // Sidebar background
  static const sidebarHover = Color(0xFF1E1E28);   // Hovered item
  static const sidebarActive = Color(0xFF252532);  // Active/selected item
}