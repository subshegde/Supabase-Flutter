import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {

  final SupabaseStorageClient supabaseClient = Supabase.instance.client.storage;

  File? imageFile;
  List<String> imageUrls = [];
  @override  
  void initState() {
    super.initState();
    fetchAllImages();
  }



  // pick image
  Future pickImage() async{
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // update image preview
    if(image != null){
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  Future uploadImage() async {
    if(imageFile == null) return;

    // generate unique filepath
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = 'uploads/$fileName';

    // upload image to supabase storage
    await Supabase.instance.client.storage.from('images').upload(filePath, imageFile!)
    .then((_)=> ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,content: Text('Image Uploaded Successfully'))));
    imageFile = null;
    fetchAllImages();
  }

List<FileObject> fileObject = [];
Future<void> fetchAllImages() async {
  try {
    fileObject.clear();
    fileObject = await supabaseClient.from('images').list(path: 'uploads');
    setState(() {});
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> removeImage(filename) async{
  supabaseClient.from('images').remove(['uploads/$filename']).then((_){
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,content: Text('Image deleted')));
    fetchAllImages();
    });
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.amber,
      title: const Text('Upload Image'),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              imageFile != null
                  ? Container(
                      margin: const EdgeInsets.only(left: 5),
                      height: 60,
                      width: 60,
                      child: Image.file(imageFile!, fit: BoxFit.contain),
                    )
                  : Container(
                      margin: const EdgeInsets.only(left: 5),
                      child: const Text('No Image Selected')),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      onPressed: uploadImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Upload', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      onPressed: pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Pick', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(color: Colors.amber[100]),
          // with pattern
          if (fileObject.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                  child: fileObject.isEmpty
                      ? const Center(child: CircularProgressIndicator(color: Colors.amber,))
                      : StaggeredGrid.count(
                          crossAxisCount: 4,
                          mainAxisSpacing: 1,
                          crossAxisSpacing: 1,
                          children: List.generate(
                            fileObject.length,
                            (index) {
                              if (fileObject[index].name == '.emptyFolderPlaceholder' || fileObject[index].name.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              final pattern = [
                                const QuiltedGridTile(2, 2),
                                const QuiltedGridTile(1, 1),
                                const QuiltedGridTile(1, 1),
                                const QuiltedGridTile(1, 2),
                              ];

                              final imageUrl = 'https://osxnoxollswbazmkhtsu.supabase.co/storage/v1/object/public/images/uploads/${fileObject[index].name}';

                              return StaggeredGridTile.count(
                                crossAxisCellCount: pattern[index % pattern.length].crossAxisCount,
                                mainAxisCellCount: pattern[index % pattern.length].mainAxisCount,
                                child: Stack(
                                  children: [
                                    // Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    Positioned(
                                      right: -7,
                                      top: -7,
                                      child: IconButton(
                                        onPressed: () async {
                                          await removeImage(fileObject[index].name);
                                        },
                                        icon: Container(
                                          height: 30,
                                          width: 30,
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(.7),borderRadius: BorderRadius.circular(30)),
                                          child: const Icon(Icons.delete, color: Colors.amber)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            )
        ],
      ),
    ),
  );
}
}