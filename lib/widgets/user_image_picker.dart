import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickedImage});

  final void Function(File pickedImage) onPickedImage;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;
  void pick_image() async {
    final pickedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Color.fromARGB(255, 223, 218, 218),
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: pick_image,
            icon: const Icon(
              Icons.image,
              color: Color.fromARGB(255, 36, 46, 46),
            ),
            label: const Text(
              'Pick an Image',
              style: TextStyle(color: Colors.blue),
            )),
      ],
    );
  }
}











// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class UserImagePicker extends StatefulWidget {
//   const UserImagePicker({super.key, required this.onPickedImage});

//   final void Function(File pickedImage) onPickedImage;
//   @override
//   State<UserImagePicker> createState() {
//     return _UserImagePickerState();
//   }
// }

// class _UserImagePickerState extends State<UserImagePicker> {
//   File? _pickedImageFile;

  
//   void pick_image() async {
//     final pickedImage = await ImagePicker()
//         .pickImage(source: ImageSource.camera, imageQuality: 50);

//     if (pickedImage == null) {
//       return;
//     }

//     setState(() {
//       _pickedImageFile = File(pickedImage.path);
//     });

//     widget.onPickedImage(_pickedImageFile!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CircleAvatar(
//           radius: 40,
//           backgroundColor: Color.fromARGB(255, 223, 218, 218),
//           foregroundImage:
//               _pickedImageFile != null ? FileImage(_pickedImageFile!) :  Image.asset('assets/default_image.png'),
//         ),
//         TextButton.icon(
//             onPressed: pick_image,
//             icon: const Icon(
//               Icons.image,
//               color: Color.fromARGB(255, 36, 46, 46),
//             ),
//             label: const Text(
//               'Pick an Image',
//               style: TextStyle(color: Colors.blue),
//             )),
//       ],
//     );
//   }
// }
