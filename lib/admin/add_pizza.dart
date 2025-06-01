import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/core/dialog.dart';

class AddPizzaPage extends StatefulWidget {
  const AddPizzaPage({super.key});

  @override
  State<AddPizzaPage> createState() => _AddPizzaPageState();
}

class _AddPizzaPageState extends State<AddPizzaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String _badge = 'spicy';
  File? _imageFile;

  final picker = ImagePicker();

  // Function to pick an image from the gallery.
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {}
    });
  }

  // Function to upload the selected image to Firebase Storage.
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
    } catch (_) {
      return null;
    }

    return null;
  }

  // Future<String> uploadImageToFirebase(File imageFile) async {
  //   FirebaseStorage storage = FirebaseStorage.instance;
  //   Reference ref = storage.ref().child("pizza_images/${DateTime.now()}.jpg");
  //   UploadTask uploadTask = ref.putFile(imageFile);
  //   TaskSnapshot taskSnapshot = await uploadTask;
  //   return await taskSnapshot.ref.getDownloadURL();
  // }

  // Function to add the pizza details to Firestore.
  Future<void> addPizzaToFirestore(String name, String description,
      double price, String imageUrl, String badge) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('pizzas').add({
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'badge': badge,
    });
  }

  // Function to validate the form, upload the image, and add pizza data to Firestore.
  Future<void> submitPizzaData(BuildContext context) async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      // Check if the form is valid and an image is selected.
      String imageUrl = await uploadImageToCloudinary(_imageFile!) ?? '';
      await addPizzaToFirestore(
        _nameController.text,
        _descriptionController.text,
        double.parse(_priceController.text),
        imageUrl,
        _badge,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pizza added successfully!')));
      _formKey.currentState!.reset();
      setState(() {
        _imageFile = null;
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
      });
      showDialogSuccess(context, "Thêm bánh thành công");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng điền đẩy đủ thông tin và chọn ảnh',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tạo món Pizza',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên Pizza'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên pizza';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _badge,
                items: ['spicy', 'non-veg'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _badge = newValue!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Badge'),
              ),
              const SizedBox(height: 20),
              _imageFile != null
                  ? InkWell(
                      onTap: pickImage,
                      child: Image.file(
                        _imageFile!,
                        height: 200,
                        width: double.infinity,
                      ),
                    )
                  : InkWell(
                      onTap: pickImage,
                      child: Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, size: 100)),
                    ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () async {
                    await submitPizzaData(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ColorApp.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: Colors.white),
                  child: const Text('Thêm bánh Pizza'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
