import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erion_news/functions/api_response.dart';
import 'package:erion_news/functions/tabs.dart';

class NewsList {
  static const apiKey = '735e70eb3b5b40c1ae8030e6eceb0373';
  static String apiUrl =
      'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

  Future<ApiResponse<List<Tabs>>> getNewsList(String country) async {
    // Update apiUrl based on the selected country
    apiUrl =
        'https://newsapi.org/v2/top-headlines?country=$country&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'ok') {
          final List<dynamic> articles = jsonData['articles'];
          final List<Tabs> tabList = articles.map((article) {
            return Tabs(
              imageURL: article['urlToImage'] ?? '',
              title: article['title'] ?? '',
              date: article['publishedAt'] ?? '',
              description: article['description'] ?? '',
              webpage: article['url'] ?? '',
            );
          }).toList();
          return ApiResponse<List<Tabs>>(data: tabList);
        } else {
          return ApiResponse<List<Tabs>>(
            data: [],
            error: true,
            errorMessage: 'Failed to fetch data: ${jsonData['message']}',
          );
        }
      } else {
        return ApiResponse<List<Tabs>>(
          data: [],
          error: true,
          errorMessage: 'Failed to fetch data: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<Tabs>>(
        data: [],
        error: true,
        errorMessage: 'An error occurred: $e',
      );
    }
  }
}
