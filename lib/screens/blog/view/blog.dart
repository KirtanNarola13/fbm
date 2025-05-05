import 'dart:convert';
import 'package:fbm_admin/Api/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

// Blog Model Class
class Blog {
  final String id;
  final String title;
  final String content;
  final String thumbnail;
  final String createdAt;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.thumbnail,
    required this.createdAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['_id'],
      title: json['title'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      createdAt: json['createdAt'],
    );
  }
}

class CreateBlogScreen extends StatefulWidget {
  @override
  _CreateBlogScreenState createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? imageFile;
  List<Blog> blogs = [];
  bool isLoading = false;

  Future<void> fetchBlogs() async {
    try {
      final response = await http.get(Uri.parse(Api.getAllBlog));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            blogs =
                (data['blogs'] as List)
                    .map((blog) => Blog.fromJson(blog))
                    .toList()
                    .reversed
                    .toList(); // Reverse the list to show newer blogs first
          });
        }
      }
    } catch (e) {
      print('Error fetching blogs: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBlogs();
  }

  Future<void> createBlog({
    required String title,
    required String content,
    required File image,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      var uri = Uri.parse(Api.createBlog);
      var request = http.MultipartRequest('POST', uri);
      request.fields['title'] = title;
      request.fields['content'] = content;
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'thumbnail',
        stream,
        length,
        filename: basename(image.path),
      );
      request.files.add(multipartFile);
      var response = await request.send();
      if (response.statusCode == 200) {
        titleController.clear();
        descriptionController.clear();
        imageFile = null;
        fetchBlogs();
      }
    } catch (e) {
      print('Error creating blog: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteBlog(String blogId) async {
    try {
      final response = await http.delete(
        Uri.parse(Api.deleteBlog),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': blogId}),
      );

      if (response.statusCode == 200) {
        fetchBlogs(); // Refresh the blog list after deletion
      } else {
        print('Failed to delete blog: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error deleting blog: $e');
    }
  }

  Future<void> chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Blog')),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: chooseImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child:
                                imageFile == null
                                    ? Center(child: Text('Tap to choose image'))
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => createBlog(
                                    title: titleController.text,
                                    content: descriptionController.text,
                                    image: imageFile!,
                                  ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              isLoading
                                  ? CircularProgressIndicator()
                                  : Text(
                                    'Save Blog',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Blogs',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child:
                        blogs.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                              itemCount: blogs.length,
                              itemBuilder: (context, index) {
                                final blog = blogs[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        blog.thumbnail,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    title: Text(blog.title),
                                    subtitle: Text(
                                      blog.content,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => deleteBlog(blog.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
