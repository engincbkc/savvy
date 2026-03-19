import 'package:lucide_icons/lucide_icons.dart';

/// Icon tokens — centralized icon mapping.
abstract class AppIcons {
  // ─── Navigation ──────────────────────────────────────────────────
  static const home = LucideIcons.home;
  static const analytics = LucideIcons.barChart;
  static const simulate = LucideIcons.sparkles;
  static const settings = LucideIcons.settings;

  // ─── Financial Fields ────────────────────────────────────────────
  static const income = LucideIcons.trendingUp;
  static const expense = LucideIcons.trendingDown;
  static const savings = LucideIcons.coins;
  static const balance = LucideIcons.wallet;
  static const networth = LucideIcons.landmark;

  // ─── Expense Categories ──────────────────────────────────────────
  static const rent = LucideIcons.building2;
  static const market = LucideIcons.shoppingCart;
  static const transport = LucideIcons.car;
  static const bills = LucideIcons.zap;
  static const health = LucideIcons.heartPulse;
  static const education = LucideIcons.graduationCap;
  static const food = LucideIcons.utensils;
  static const fun = LucideIcons.gamepad2;
  static const clothing = LucideIcons.shirt;
  static const subscription = LucideIcons.rss;
  static const loan = LucideIcons.banknote;
  static const tax = LucideIcons.receipt;
  static const ad = LucideIcons.megaphone;

  // ─── Income Categories ───────────────────────────────────────────
  static const salary = LucideIcons.briefcase;
  static const freelance = LucideIcons.laptop;
  static const transfer = LucideIcons.arrowLeftRight;
  static const investment = LucideIcons.lineChart;
  static const gift = LucideIcons.gift;

  // ─── Savings Categories ──────────────────────────────────────────
  static const emergency = LucideIcons.shieldCheck;
  static const goal = LucideIcons.target;
  static const gold = LucideIcons.coins;
  static const stock = LucideIcons.candlestickChart;
  static const retirement = LucideIcons.sunMedium;

  // ─── Actions ─────────────────────────────────────────────────────
  static const add = LucideIcons.plus;
  static const edit = LucideIcons.pencil;
  static const delete = LucideIcons.trash2;
  static const search = LucideIcons.search;
  static const filter = LucideIcons.filter;
  static const sort = LucideIcons.arrowUpDown;
  static const share = LucideIcons.share2;
  static const download = LucideIcons.download;
  static const upload = LucideIcons.upload;
  static const copy = LucideIcons.copy;
  static const check = LucideIcons.check;
  static const close = LucideIcons.x;
  static const back = LucideIcons.chevronLeft;
  static const forward = LucideIcons.chevronRight;
  static const expand = LucideIcons.chevronDown;
  static const info = LucideIcons.info;
  static const warning = LucideIcons.alertTriangle;
  static const ai = LucideIcons.bot;
  static const recurring = LucideIcons.repeat;
  static const category = LucideIcons.tag;
  static const calendar = LucideIcons.calendar;
  static const note = LucideIcons.fileText;
  static const person = LucideIcons.user;
  static const darkMode = LucideIcons.moon;
  static const lightMode = LucideIcons.sun;
  static const lock = LucideIcons.lock;
  static const logout = LucideIcons.logOut;
}

/// Icon size tokens.
abstract class AppIconSize {
  static const double xs = 14.0;
  static const double sm = 16.0;
  static const double md = 20.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xl2 = 48.0;
}
