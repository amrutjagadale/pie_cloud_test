import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart' as email_sender;
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _populateUserEmail();
  }

  void _populateUserEmail() {
    final User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _emailController.text = user?.email ?? "default@example.com";
    });
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) return; // Limit to a maximum of 3 images
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _sendFeedback() async {
    if (_feedbackController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your question")),
      );
      return;
    }

    if (_isSending) return; // Prevent multiple taps
    setState(() => _isSending = true);

    // Build the attachments list dynamically based on how many images are selected.
    // This list can have 0, 1, 2, or 3 items.
    List<String> attachments = _selectedImages.map((file) => file.path).toList();
    debugPrint("Number of attachments: ${attachments.length}");

    final email_sender.Email email = email_sender.Email(
      body: _feedbackController.text,
      subject: 'User Feedback',
      recipients: ['amrutj0056@gmail.com'], // Change to your support email
      attachmentPaths: attachments,
      isHTML: false,
    );

    try {
      await email_sender.FlutterEmailSender.send(email);
      _showThankYouDialog();
      _clearForm();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send feedback")),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _clearForm() {
    setState(() {
      _feedbackController.clear();
      _selectedImages.clear();
    });
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Thank You!"),
          content: Text("Your feedback has been submitted successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feedback")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email field pre-filled with the logged-in user's email.
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _emailController.clear(),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Multiline feedback field.
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Your detailed question",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text("Attach Images (Max 3)"),
            Row(
              children: [
                // Display each selected image.
                ..._selectedImages.map(
                      (file) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Stack(
                      children: [
                        Image.file(file, width: 70, height: 70, fit: BoxFit.cover),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.remove(file);
                              });
                            },
                            child: Container(
                              color: Colors.black54,
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Show an add button if less than 3 images are selected.
                if (_selectedImages.length < 3)
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(Icons.add, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _isSending ? null : _sendFeedback,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isSending
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

