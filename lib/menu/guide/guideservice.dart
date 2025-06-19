import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:legalito/menu/guide/guide.dart';

class GuideService {
  final String _baseUrl = 'https://legalito-5ee33-default-rtdb.firebaseio.com/problems.json';

  Future<List<Guide>> fetchProblems() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final Map<String, dynamic> data = json.decode(response.body);

        // Convert the map of problems into a list of Problem objects
        final List<Guide> problems = [];
        data.forEach((key, value) {
          // We are ignoring the key (like "as" or "dsfsdf") and only using the inner object
          problems.add(Guide.fromJson(value));
        });

        return problems;
      } else {
        // Handle non-200 status codes
        print('Failed to load problems: ${response.statusCode}');
        return []; // Return an empty list or throw an exception
      }
    } catch (e) {
      // Handle any errors during the HTTP request
      print('Error fetching problems: $e');
      return []; // Return an empty list or throw an exception
    }
  }
}
