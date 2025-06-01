import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pizza_delivery_app/core/color_app.dart';

class UpdatePizzaPage extends StatefulWidget {
  final String pizzaId;

  const UpdatePizzaPage({super.key, required this.pizzaId});

  @override
  State<UpdatePizzaPage> createState() => _UpdatePizzaPageState();
}

class _UpdatePizzaPageState extends State<UpdatePizzaPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _badgeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  File? _selectedImage;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPizzaData();
  }

  // Load the pizza data from Firestore and populate the text fields
  Future<void> _loadPizzaData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('pizzas')
        .doc(widget.pizzaId)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      _nameController.text = data['name'] ?? ''; // Set name
      _descriptionController.text =
          data['description'] ?? ''; // Set description
      _badgeController.text = data['badge'] ?? ''; // Set badge
      _priceController.text = data['price'].toString(); // Set price
      _imageUrl = data['imageUrl'] ?? ''; // Set image URL
    });
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const String cloudName = "dgfmiwien";
    const String apiKey = "BvZZdKGI6pq4C8QrALmkZWt2MnY";
    const String uploadPreset = "pizza_store";

    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path),
        "upload_preset": uploadPreset,
        "api_key": apiKey,
      });

      Response response = await Dio().post(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data["secure_url"] as String?;
      }
    } catch (_) {}

    return null;
  }

  Future<void> _updatePizza() async {
    String imageUrl = _imageUrl ?? '';

    if (_selectedImage != null) {
      imageUrl = await uploadImageToCloudinary(_selectedImage!) ?? '';
    }

    // Update the Firestore document with new data
    await FirebaseFirestore.instance
        .collection('pizzas')
        .doc(widget.pizzaId)
        .update({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'badge': _badgeController.text,
      'price': double.parse(_priceController.text),
      'imageUrl': imageUrl,
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pizza updated successfully')),
    );

    Navigator.pop(context);
  }

  // Delete the pizza from Firestore
  Future<void> _deletePizza() async {
    await FirebaseFirestore.instance
        .collection('pizzas')
        .doc(widget.pizzaId)
        .delete();

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pizza deleted successfully')),
    );

    Navigator.pop(context);
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cập nhật bánh pizza',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên bánh Pizza'),
            ),
            const SizedBox(height: 10),
            // Text field for pizza description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
            const SizedBox(height: 10),
            // Text field for pizza badge
            TextField(
              controller: _badgeController,
              decoration: const InputDecoration(labelText: 'Badge'),
            ),
            const SizedBox(height: 10),
            // Text field for pizza price
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            // Display the selected image or existing image from URL
            _selectedImage == null && _imageUrl != null
                ? InkWell(
                    onTap: _pickImage,
                    child: Image.network(
                      _imageUrl!,
                      height: 200,
                    ),
                  )
                : _selectedImage != null
                    ? InkWell(
                        onTap: _pickImage,
                        child: Image.file(
                          _selectedImage!,
                          height: 200,
                        ),
                      )
                    : InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          color: Colors.grey[200],
                        ),
                      ),
            const SizedBox(height: 30),

            // Row containing Update and Delete buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _updatePizza,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorApp.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Colors.white),
                    child: const Text('Update'),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _deletePizza, // Call delete pizza function
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                        foregroundColor: Colors.white),
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
