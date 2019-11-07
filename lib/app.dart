import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conferenceapp/agenda/repository/talks_repository.dart';
import 'package:conferenceapp/main_page/home_page.dart';
import 'package:conferenceapp/profile/auth_repository.dart';
import 'package:conferenceapp/profile/favorites_repository.dart';
import 'package:conferenceapp/profile/user_repository.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => ThemeData(
        primarySwatch: Colors.blue,
        accentColor: brightness == Brightness.light
            ? Colors.orange[300]
            : Colors.orange[800],
        toggleableActiveColor: Colors.orange[800],
        dividerColor:
            brightness == Brightness.light ? Colors.white : Colors.white54,
        brightness: brightness,
        fontFamily: 'PTSans',
        bottomAppBarTheme: Theme.of(context).bottomAppBarTheme.copyWith(
              elevation: 0,
            ),
      ),
      themedWidgetBuilder: (context, theme) {
        return RepositoryProviders(
          child: MaterialApp(
            title: title,
            theme: theme,
            home: HomePage(title: title),
          ),
        );
      },
    );
  }
}

class RepositoryProviders extends StatelessWidget {
  final Widget child;

  const RepositoryProviders({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      builder: (_) => AuthRepository(FirebaseAuth.instance),
      child: RepositoryProvider(
        builder: _userRepositoryBuilder,
        child: RepositoryProvider<TalkRepository>(
          builder: (_) => FirestoreTalkRepository(),
          child: RepositoryProvider(
            builder: _favoritesRepositoryBuilder,
            child: child,
          ),
        ),
      ),
    );
  }

  UserRepository _userRepositoryBuilder(BuildContext context) {
    return UserRepository(
      RepositoryProvider.of<AuthRepository>(context),
      Firestore.instance,
    );
  }

  FavoritesRepository _favoritesRepositoryBuilder(BuildContext context) {
    return FavoritesRepository(
      RepositoryProvider.of<TalkRepository>(context),
      RepositoryProvider.of<UserRepository>(context),
    );
  }
}