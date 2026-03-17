import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('News'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
              tooltip: 'Search',
            ),
          ],
          actionsPadding: const EdgeInsets.only(right: 12),
        ),
        body: FutureBuilder<List<Post>>(
          future: fetchPost(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Image.network(posts[index].urlToImage),
                        const SizedBox(height: 10),
                        Text(
                          posts[index].title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          posts[index].description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Text('No data found');
            }
          },
        ),
      ),
    );
  }
}

class Post {
  final String title;
  final String description;
  final String urlToImage;
  Post({
    required this.title,
    required this.description,
    required this.urlToImage,
  });
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      urlToImage: json['urlToImage'] ?? "",
    );
  }
}

Future<List<Post>> fetchPost() async {
  List<Post> posts = [];
  final url = Uri.parse(
    'https://newsapi.org/v2/everything?q=tesla&from=2025-11-26&sortBy=publishedAt&apiKey=7d5748875f7349bb8a9423e613ac8792',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    for (int i = 0; i < data['articles'].length; i++) {
      posts.add(Post.fromJson(data['articles'][i]));
    }
  } else {
    throw Exception('Failed to load post');
  }
  return posts;
}
