import 'package:http/http.dart' as http;
import 'dart:convert';

class LLMChatbotService {
  // API keys must be provided via build/runtime configuration.
  // Use `--dart-define=GROQ_API_KEY=...` and `--dart-define=HF_API_KEY=...` when building.
  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // Using Hugging Face Inference API as fallback (also free)
  static const String _huggingFaceKey = String.fromEnvironment('HF_API_KEY', defaultValue: '');
  static const String _huggingFaceUrl = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1';

  static const Duration _timeout = Duration(seconds: 15);

  /// Send a message to the LLM and get a response
  static Future<String> chat({
    required String userMessage,
    required String context, // Tourist's location, safety info, etc.
  }) async {
    print('\n========== CHAT START ==========');
    print('📝 Message: "$userMessage"');
    
    try {
      // Try Groq first
      print('🔄 Trying Groq...');
      final groqResponse = await _callGroqAPI(userMessage, context);
      
      if (groqResponse.isNotEmpty) {
        print('✅ Groq SUCCESS');
        print('========== CHAT END ==========\n');
        return groqResponse;
      }
      
      print('⚠️ Groq failed, trying HF...');
      final hfResponse = await _callHuggingFaceAPI(userMessage, context);
      
      if (hfResponse.isNotEmpty) {
        print('✅ HF SUCCESS');
        print('========== CHAT END ==========\n');
        return hfResponse;
      }

      print('❌ All APIs failed - both returned empty');
      print('========== CHAT END ==========\n');
      return "❌ AI service error. Restart app or try Groq key setup.";
    } catch (e) {
      print('💥 CHAT Exception: $e');
      print('========== CHAT END (ERROR) ==========\n');
      return "Error: ${e.toString()}";
    }
  }

  /// Call Groq API
  static Future<String> _callGroqAPI(String userMessage, String context) async {
    try {
      print('  [Groq] Creating request...');
      
      final payload = {
        'model': 'llama-3.1-8b-instant', // Updated: Changed from deprecated mixtral model
        'messages': [
          {'role': 'system', 'content': 'You are SafetySafar safety assistant. Answer in 1-2 sentences.'},
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': 0.7,
        'max_tokens': 150,
      };

      print('  [Groq] Sending HTTP POST...');
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      print('  [Groq] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          final content = data['choices'][0]['message']['content'];
          print('  [Groq] ✅ Got response: ${content.length} chars');
          return content;
        } catch (e) {
          print('  [Groq] ❌ Failed to parse: $e');
          print('  [Groq] Body: ${response.body}');
          return '';
        }
      } else {
        print('  [Groq] ❌ HTTP ${response.statusCode}');
        print('  [Groq] Body: ${response.body}');
        return '';
      }
    } catch (e) {
      print('  [Groq] ❌ Exception: $e');
      return '';
    }
  }

  /// Call Hugging Face API (fallback)
  static Future<String> _callHuggingFaceAPI(String userMessage, String context) async {
    try {
      final prompt = '''SafetySafar Safety Assistant

Context: $context

User Question: $userMessage

Respond with safety advice for tourists in India. Be concise and actionable.

Response:''';

      final response = await http
          .post(
            Uri.parse(_huggingFaceUrl),
            headers: {
              'Authorization': 'Bearer $_huggingFaceKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'inputs': prompt,
              'parameters': {
                'max_length': 500,
                'temperature': 0.7,
              },
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data[0]['generated_text']?.replaceFirst(prompt, '').trim() ?? 'No response';
        }
      }
      return '';
    } catch (e) {
      print('Hugging Face Error: $e');
      return '';
    }
  }

  /// Test if Groq API is accessible
  static Future<String> testGroqConnection() async {
    try {
      print('🧪 Testing Groq API connection...');
      
      final testPayload = {
        'model': 'mixtral-8x7b-32768',
        'messages': [
          {'role': 'user', 'content': 'Say "OK" only'},
        ],
        'max_tokens': 10,
      };

      print('📤 Test Payload: ${jsonEncode(testPayload)}');
      print('🔑 Using Key: ${_groqApiKey.substring(0, 20)}...');

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(testPayload),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'] ?? '';
        return 'SUCCESS: $content';
      } else if (response.statusCode == 401) {
        return 'ERROR 401: Invalid API Key - Check your Groq key';
      } else if (response.statusCode == 429) {
        return 'ERROR 429: Rate limited - Try again later';
      } else {
        return 'ERROR ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'EXCEPTION: $e';
    }
  }

  /// Check if API keys are configured (not using placeholder values)
  static bool isConfigured() {
    bool hasGroqKey = _groqApiKey.startsWith('gsk_') && _groqApiKey != 'gsk_nxKzF8qP1M2nR3oQ4sT5uV6wX7yZ8aB';
    bool hasHFKey = _huggingFaceKey.startsWith('hf_') && _huggingFaceKey != 'hf_FKvzPqRstuVwXyZaBcDeFgHiJkLmNoPq';
    
    print('🔍 Config Check: Groq=$hasGroqKey, HF=$hasHFKey');
    print('   Groq Key starts with: ${_groqApiKey.substring(0, 10)}...');
    
    return hasGroqKey || hasHFKey;
  }

  /// Get setup instructions
  static String getSetupInstructions() {
    return '''To enable AI Assistant:



OR use Hugging Face:
1. Go to https://huggingface.co/settings/tokens
2. Create free account
3. Get API token
4. Replace _huggingFaceKey value''';
  }
}
