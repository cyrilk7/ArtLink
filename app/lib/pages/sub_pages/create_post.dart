import 'dart:io';

import 'package:ashlink/controllers/post_controller.dart';
import 'package:ashlink/widgets/custom_icon_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _controller = TextEditingController();
  final postController = PostController();
  File? _postImage;
  bool postButtonEnabled = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _postImage = File(pickedFile.path);
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _postImage = null;
    });
  }

  void _postContent() async {
    final content = _controller.text;
    try {
      if (content.isNotEmpty) {
        await postController.createPost(content, _postImage);
        Navigator.pop(context, true); // Navigate back after posting
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        postButtonEnabled = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        leading: CustomIconButton(
          buttonIcon: Icons.arrow_back,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '',
              style: GoogleFonts.museoModerno(
                textStyle: const TextStyle(
                  color: Color.fromARGB(255, 70, 111, 201),
                  fontWeight: FontWeight.bold,
                  // fontSize: 22,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              height: 40,
              child: FloatingActionButton(
                onPressed: postButtonEnabled ? () {
                  _postContent();
                } : null,
                backgroundColor: postButtonEnabled ? const Color.fromARGB(255, 70, 111, 201): Colors.grey,
                child: const Text('Post',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: postButtonEnabled
                ? Container()
                : const Opacity(
                    opacity: 0.5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 248, 248, 248),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      _pickImage();
                      // Handle image attachment
                    },
                  ),
                ),
                if (_postImage != null) ...[
                  const SizedBox(height: 10),
                  Image.file(
                    _postImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteImage,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
