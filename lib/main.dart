import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context,AsyncSnapshot<FirebaseUser> snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting)
          return SplashPage();
        if(!snapshot.hasData || snapshot.data == null)
          return LoginPage();
        return HomePage();
      },
    );
  }
}
 class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
  return Scaffold(
  body: Container(
  color: Theme.of(context).primaryColor,
  child: SafeArea(
  child: Container(
  width: double.infinity,
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: <Widget>[
  CircularProgressIndicator(
  backgroundColor: Colors.white,
  ),
  const SizedBox(height: 10.0),
  Text("Loading", style: TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w400,
  fontSize: 18.0
  ),),
  ],
  ),
  ),
  ),
  ),
  );
  }
  }
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Home page"),
            RaisedButton(
              child: Text("Log out"),
              onPressed: (){
                AuthProvider().logOut();
              },
            )
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController;
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:Text("Login Page"),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100.0),
              Text("Login", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0
              ),textAlign: TextAlign.center,),
              const SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    hintText: "Enter email"
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    hintText: "Enter password"
                ),
              ),
              const SizedBox(height: 10.0),

                        RaisedButton(
                       child: Text("Login"),

                         onPressed: ()async {
                         if(_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                           print("Email and password cannot be empty");
                             return;
                        }
                         bool res = await AuthProvider().signInWithEmail(_emailController.text, _passwordController.text);
                         if(!res) {
                       print("Login failed");
                  }
                },
              ),

          RaisedButton(
            child: Text("Login with Google"),
            onPressed: () async {
              bool res = await AuthProvider().loginWithGoogle();
              if(!res)
                print("error logging in with google");
            },
          ),
              ],
              ),
          ),
        ),
      );
  }
}
class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signInWithEmail(String email, String password) async{
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email,password: password);
      FirebaseUser user = result.user;
      if(user != null)
        return true;
      else
        return false;
    } catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("error logging out");
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount account = await googleSignIn.signIn();
      if(account == null )
        return false;
      AuthResult res = await _auth.signInWithCredential(GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken,
      ));
      if(res.user == null)
        return false;
      return true;
    } catch (e) {
      print(e.message);
      print("Error logging with google");
      return false;
    }
  }
}
