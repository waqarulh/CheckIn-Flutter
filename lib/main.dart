import 'package:checkin/firebase_options.dart';
import 'package:checkin/screens/auth/login.dart';
import 'package:checkin/screens/auth/sign-up.dart';
import 'package:checkin/screens/home/home-screen.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_bloc.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_event.dart';
import 'package:checkin/services/bloc/auth-bloc/auth_state.dart';
import 'package:checkin/services/bloc/checkin-bloc/checkin_bloc.dart';
import 'package:checkin/store/storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) {
            final authBloc = AuthBloc(FirebaseAuth.instance);
            authBloc.add(CheckAuthStatusEvent());
            return authBloc;
          },
        ),
        BlocProvider<CheckInBloc>(
          create: (context) => CheckInBloc(StorageManager(prefs))..add(LoadCheckIns()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Check-in',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        initialRoute: '/',
        routes: {
          '/signup': (context) => SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
        },
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
