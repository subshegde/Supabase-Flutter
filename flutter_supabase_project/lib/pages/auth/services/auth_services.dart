import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices{

  // getting the instance of supabase
  final SupabaseClient supabase = Supabase.instance.client;


  // Sign in with email and password
  Future<AuthResponse> signInWithEmailAndPassword(String email , String password)async {
    return await supabase.auth.signInWithPassword(password: password,email: email);
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailAndPassword(String email , String password)async {
    return await supabase.auth.signUp(password: password,email: email);
  }

  // Sign out

  Future<void> signOut()async {
   await supabase.auth.signOut();
  }

  // Get User email

  String? getUserEmail(){
    final session  = supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

}