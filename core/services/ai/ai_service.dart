import 'package:googleai_dart/googleai_dart.dart';
import '../../../shared/constants/app_constants.dart';
import '../../exceptions/app_exceptions.dart';

class AiService {
  AiService._privateConstructor();
  static final AiService instance = AiService._privateConstructor();
  factory AiService() => instance;
  final googleClient = GoogleAIClient(
    config: GoogleAIConfig.googleAI(
      authProvider: ApiKeyProvider(AppConstants.googleApiKey),
      timeout: const Duration(minutes: 3),
    ),
  );

  Future<String> generateText(
      {String? prompt, String? mimeType, List<int>? bytes}) async {
    try {
      final response = await googleClient.models.generateContent(
        request: GenerateContentRequest(contents: [
          Content(
            parts: [
              Part.text(prompt ?? documentExtractionPrompt),
              Part.bytes(bytes ?? [], mimeType ?? "image/png")
            ],
          )
        ]),
        model: 'gemini-2.5-flash',
      );
      if (!response.hasContent) {
        throw FailedException("Failed to Extract text");
      }
      return cleanJson(response.text ?? "");
    } catch (e) {
      throw FailedException(e.toString());
    }
  }

  String cleanJson(String input) {
    return input
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .replaceAll(r'\n', '')
        .replaceAll(r'\"', '"')
        .trim();
  }

  static const String documentExtractionPrompt = '''
You are a highly accurate AI document extraction engine.

Your task is to analyze the uploaded document (provided as FILE BYTES) and extract ALL important visible information.

The document may be:
- Bank receipt
- POS receipt
- Purchase receipt
- Invoice
- Driver's license
- National ID card
- Passport
- Utility bill
- Tax document
- Certificate
- Medical report
- Letter
- Contract
- Any other document type

STRICT RULES:
1. Return ONLY valid JSON.
2. Do NOT return markdown.
3. Do NOT add explanations or comments.
4. Always maintain the EXACT JSON structure and keys.
5. If a value is unavailable, unreadable, or missing, return null.
6. Extract only information visible in the document.
7. Preserve original formatting for IDs, account numbers, dates, phone numbers, and transaction references.
8. Detect the document type automatically.
9. Include every key even if the value is null.
10. The response must be directly parsable using JSON.decode().
11. Do not hallucinate values.
12. Arrays must always return an array even if empty.
13. The input document is provided as binary file content (bytes), not a URL.

RETURN THIS EXACT JSON STRUCTURE:

{
  "document_type": null,
  "document_subtype": null,
  "document_title": null,
  "is_valid_document": null,

  "summary": {
    "main_subject": null,
    "description": null,
    "important_notes": []
  },

  "person": {
    "full_name": null,
    "first_name": null,
    "middle_name": null,
    "last_name": null,
    "date_of_birth": null,
    "gender": null,
    "nationality": null,
    "phone_number": null,
    "email": null,
    "address": null
  },

  "organization": {
    "name": null,
    "branch": null,
    "website": null,
    "email": null,
    "phone_number": null,
    "address": null
  },

  "financial_information": {
    "amount": null,
    "currency": null,
    "tax": null,
    "discount": null,
    "subtotal": null,
    "total": null,
    "payment_method": null,
    "transaction_reference": null,
    "transaction_id": null,
    "authorization_code": null,
    "transaction_status": null,
    "bank_name": null,
    "account_number": null,
    "account_name": null,
    "recipient_name": null,
    "sender_name": null,
    "card_type": null,
    "pos_id": null
  },

  "document_details": {
    "document_number": null,
    "reference_number": null,
    "serial_number": null,
    "license_number": null,
    "passport_number": null,
    "id_number": null,
    "invoice_number": null,
    "receipt_number": null,
    "issue_date": null,
    "expiry_date": null,
    "transaction_date": null,
    "transaction_time": null,
    "issued_by": null
  },

  "items": [
    {
      "name": null,
      "description": null,
      "quantity": null,
      "unit_price": null,
      "total_price": null
    }
  ],

  "vehicle_information": {
    "plate_number": null,
    "vehicle_make": null,
    "vehicle_model": null,
    "vehicle_color": null,
    "chassis_number": null
  },

  "metadata": {
    "detected_language": null,
    "document_format": null,
    "confidence_score": null
  },

  "raw_text": null
}
''';
}
