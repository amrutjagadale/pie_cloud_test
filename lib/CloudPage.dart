import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'DatabaseHelper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GalleryImage {
  final String imagePath;
  final String time;

  GalleryImage({required this.imagePath, required this.time});
}

class GallerySection {
  final String date;
  final List<GalleryImage> images;

  GallerySection({required this.date, required this.images});
}

class CloudPage extends StatefulWidget {
  const CloudPage({Key? key}) : super(key: key);

  @override
  _CloudPageState createState() => _CloudPageState();
}

class _CloudPageState extends State<CloudPage> {
  List<GallerySection> _gallerySections = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImagesFromDatabase();
  }

  Future<void> _loadImagesFromDatabase() async {
    // Retrieve rows from the database; each row contains an 'imagePath'
    List<Map<String, dynamic>> rows = await DatabaseHelper.instance.getImages();
    // Debug print to see what we're getting:
    print("DB rows: $rows");

    // Group images by date.
    Map<String, List<GalleryImage>> groupedImages = {};
    for (var row in rows) {
      String date = row['date'];
      String time = row['time'];
      String imagePath = row['imagePath'];
      GalleryImage galleryImage =
      GalleryImage(imagePath: imagePath, time: time);
      if (groupedImages.containsKey(date)) {
        groupedImages[date]!.add(galleryImage);
      } else {
        groupedImages[date] = [galleryImage];
      }
    }

    // Convert the map to a list of GallerySection objects.
    List<GallerySection> sections = [];
    groupedImages.forEach((date, images) {
      images.sort((a, b) => b.time.compareTo(a.time)); // Newest first
      sections.add(GallerySection(date: date, images: images));
    });

    // Sort sections by date (newest first)
    sections.sort((a, b) {
      DateTime dateA = DateFormat('dd/MM/yyyy').parse(a.date);
      DateTime dateB = DateFormat('dd/MM/yyyy').parse(b.date);
      return dateB.compareTo(dateA);
    });

    setState(() {
      _gallerySections = sections;
    });
  }

  Future<void> _showImageSourcePicker() async {

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title:  Text(AppLocalizations.of(context)!.gallery),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title:  Text(AppLocalizations.of(context)!.camera),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      // Copy the file to the app's persistent directory.
      String savedPath =
      await DatabaseHelper.instance.saveImageToFileSystem(imageFile);
      await _saveImageToDatabase(savedPath);
    }
  }

  /// Saves the file path along with the current date and time into SQLite.
  Future<void> _saveImageToDatabase(String imagePath) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    String formattedTime = DateFormat('HH:mm:ss').format(now);

    await DatabaseHelper.instance.insertImage(imagePath, formattedDate, formattedTime);
    await _loadImagesFromDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(AppLocalizations.of(context)!.imageSaved
      )),
    );
  }

  /// Builds a grid item that loads the image using its file path.
  Widget _buildImageItem(GalleryImage galleryImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(galleryImage.imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          galleryImage.time,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.cloudGallery
        ),
      ),
      body: ListView.builder(
        itemCount: _gallerySections.length,
        itemBuilder: (context, sectionIndex) {
          final section = _gallerySections[sectionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  section.date,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              // Grid of images for this date.
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: section.images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.3,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, imageIndex) {
                  final galleryImage = section.images[imageIndex];
                  return _buildImageItem(galleryImage);
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showImageSourcePicker,
        child: const Icon(Icons.add),
      ),
    );
  }
}


