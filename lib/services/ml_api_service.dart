// lib/services/ml_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class MLApiService {
  static Future<List<String>> obtenerMarcas() async {
    final res = await http.get(
      Uri.parse('https://api.mercadolibre.com/sites/MLA/categories/MLA1743/attributes'),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final atributoMarca = (data as List)
          .firstWhere((a) => a['id'] == 'BRAND', orElse: () => null);

      if (atributoMarca == null) throw Exception('No se encontró el atributo BRAND');

      final valores = atributoMarca['values'] as List;
      return valores.map((v) => v['name'].toString()).toList()..sort();
    } else {
      throw Exception('Error al obtener marcas de Mercado Libre');
    }
  }
}
