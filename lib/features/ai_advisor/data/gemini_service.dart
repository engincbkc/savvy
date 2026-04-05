import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class GeminiService {
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  late final GenerativeModel _model;
  late final ChatSession _chat;

  bool get isConfigured => _apiKey.isNotEmpty;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model.startChat();
  }

  static const String _systemPrompt = '''
Sen Savvy adlı kişisel finans uygulamasının yapay zeka danışmanısın.
Türkçe konuş. Kullanıcının finansal verilerini analiz ederek pratik, kişisel tavsiyeler ver.
Kısa ve öz ol. Gereksiz tekrar yapma. Para birimlerini ₺ ile göster.
Yalnızca finansal konularda yardım et.
''';

  Future<String> sendMessage(String userMessage, String financialContext) async {
    if (!isConfigured) {
      return 'API anahtarı yapılandırılmamış. Lütfen ayarlardan GEMINI_API_KEY ekleyin.';
    }
    try {
      final response = await _chat.sendMessage(
        Content.text('Finansal Bağlam:\n$financialContext\n\nSoru: $userMessage'),
      );
      return response.text ?? 'Yanıt alınamadı.';
    } catch (e) {
      return 'Hata: $e';
    }
  }

  static String buildContext(List<MonthSummary> recentMonths) {
    if (recentMonths.isEmpty) return 'Henüz veri yok.';
    final latest = recentMonths.first;
    final lines = <String>[
      'Bu ayki gelir: ${latest.totalIncome.toStringAsFixed(0)}₺',
      'Bu ayki gider: ${latest.totalExpense.toStringAsFixed(0)}₺',
      'Net bakiye: ${latest.netBalance.toStringAsFixed(0)}₺',
      'Tasarruf oranı: %${(latest.savingsRate * 100).toStringAsFixed(1)}',
    ];
    if (recentMonths.length > 1) {
      final prev = recentMonths[1];
      lines.add('Önceki ay net: ${prev.netBalance.toStringAsFixed(0)}₺');
    }
    return lines.join('\n');
  }
}
