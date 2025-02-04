/*    

AUTH Gate - this contineously listen for the auth state change
---------------------------------------------------------------

unauthenticated -> go to login page
authenticated -> continue to the app ( Note page )

*/

import 'package:flutter/material.dart';
import 'package:flutter_supabase_project/pages/auth/pages/signin.dart';
import 'package:flutter_supabase_project/pages/home/homeMain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // listen to the auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange, 
      builder: (context , snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator(color: Colors.deepPurple,)),
          );
        }
        // check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if(session != null){
          return const HomeMain();
        }else{
          return const SignIn();
        }
      },
      
      
      );
  }
}