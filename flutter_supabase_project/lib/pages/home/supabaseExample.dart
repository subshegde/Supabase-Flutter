import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_supabase_project/pages/auth/services/auth_services.dart';
import 'package:flutter_supabase_project/pages/home/profile.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseExample extends StatefulWidget {
  const SupabaseExample({super.key});

  @override
  State<SupabaseExample> createState() => _SupabaseExampleState();
}

class _SupabaseExampleState extends State<SupabaseExample> {

  final TextEditingController textController = TextEditingController();
  final TextEditingController editTextController = TextEditingController();
  final TextEditingController email = TextEditingController();

  final AuthServices services = AuthServices();


  @override  
  void initState() {
    super.initState();
    getEmail();
  }


  @override  
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void getEmail() {
    email.text = services.getUserEmail() ??'';
  }

  
  // CREATE - a note and save in supabase

void addNewNote() {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text(
        'Add a New Note',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CupertinoTextField(
          controller: textController,
          placeholder: 'Enter your note here...',
          style: const TextStyle(color: Colors.black),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            if (textController.text.isNotEmpty) {
              saveNote();
              textController.clear();
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a note!')),
              );
            }
            setState(() {});
          },
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}


void editNewNote(int id) {
  showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text(
        'Edit a note',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CupertinoTextField(
          controller: editTextController,
          placeholder: 'Enter your note here...',
          style: const TextStyle(color: Colors.black),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            if (editTextController.text.isNotEmpty) {
              updateNote(editTextController.text, id);
              editTextController.clear();
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a note!')),
              );
            }
            setState(() {});
          },
          child: const Text(
            'Edit',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}



  void saveNote() async{
    await Supabase.instance.client.from('notes').insert({'body': textController.text});
  }

  //READ - all notes from supabase
  final notesStream = Supabase.instance.client.from('notes').stream(primaryKey: ['id']);


  Future<void> updateNote(String body,int id)async{
    await Supabase.instance.client.from('notes').update({'body':body}).eq('id', id);
  }


    Future<void> deleteNote(int id)async{
    await Supabase.instance.client.from('notes').delete().eq('id', id);
  }


Future<void> showConfirmationDialog(BuildContext context,int deleteId) async {
  return showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text(
        'Are you sure?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        'Do you really want to delete this item? This action cannot be undone.',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.black),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          child: const Text(
            'Delete',
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            deleteNote(deleteId);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item Deleted')),
            );
          },
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(email: email.text,)));
            },
          child: const Icon(Icons.person, color: Colors.white)),
        foregroundColor: Colors.white,
        title: const Text('Notes',style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: (){
              Supabase.instance.client.auth.signOut();
            }, 
            icon: const Icon(Icons.logout,))
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: 
      FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        onPressed: addNewNote,
        child: const Icon(Icons.add),
        ),

        body: StreamBuilder<List<Map<String ,dynamic>>>(
          stream: notesStream, 
          builder: (context, snapshot) {
            // loading
            if(!snapshot.hasData){
              return const Center(child: CircularProgressIndicator(color: Colors.amber,),);
            }
            //loaded
            final notes = snapshot.data;
            return ListView.builder(
              itemCount: notes!.length,
              itemBuilder: (context , index){
                // getting individual note
                var note = notes[index];
                return  NotesItem(
                  data: note['body'],
                  id: note['id'],
                  onEdit: (id){
                    editNewNote(id);
                  },
                  onDelete: (id){
                    showConfirmationDialog(context, id);
                    setState(() {});
                  },
                  );
              }
              );
          },
          ),
    );
  }
}

class NotesItem extends StatefulWidget {
  final String data;
  final int id;
  final Function(int id)onEdit;
  final Function(int id)onDelete;
  const NotesItem({required this.data,required this.id,required this.onEdit,required this.onDelete});

  @override
  State<NotesItem> createState() => _NotesItemState();
}

class _NotesItemState extends State<NotesItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(
                  Icons.note,
                  color: Colors.amber,
                  size: 30,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.data,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                ),
              ),
              GestureDetector(
                onTap: (){
                  widget.onEdit(widget.id);
                },
                child: Container(
                height: 30,
                width: 30,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.7),borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              GestureDetector(
                onTap: (){
                  widget.onDelete(widget.id);
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.7),borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
