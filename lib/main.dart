import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/all_recipes_screen.dart';
import 'screens/add_edit_recipe_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'helpers/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeNotifications();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          // Dynamic theme color
          Color getSeedColor(String color) {
            switch (color) {
              case 'green':
                return Colors.green;
              case 'blue':
                return Colors.blue;
              case 'purple':
                return Colors.purple;
              default:
                return const Color(0xFF7B3F00);
            }
          }
          final Color seedColor = getSeedColor(appProvider.themeColor);
          final Color primaryColor = seedColor;
          final Color secondaryColor = appProvider.themeColor == 'green'
              ? Colors.lightGreen
              : appProvider.themeColor == 'blue'
                  ? Colors.lightBlueAccent
                  : appProvider.themeColor == 'purple'
                      ? Colors.deepPurpleAccent
                      : const Color(0xFFE07A5F);
          final Color backgroundColor = appProvider.themeColor == 'green'
              ? const Color(0xFFE8F5E9)
              : appProvider.themeColor == 'blue'
                  ? const Color(0xFFE3F2FD)
                  : appProvider.themeColor == 'purple'
                      ? const Color(0xFFF3E5F5)
                      : const Color(0xFFF5E9DA);

          ThemeData lightTheme = ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              primary: primaryColor,
              secondary: secondaryColor,
              tertiary: backgroundColor,
              background: backgroundColor,
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Color(0xFF3E2723),
              onSurface: Color(0xFF3E2723),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ).apply(bodyColor: Color(0xFF3E2723)),
            scaffoldBackgroundColor: backgroundColor,
            fontFamily: 'Roboto',
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: secondaryColor, width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF9F6F2),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey,
              elevation: 8,
              type: BottomNavigationBarType.fixed,
            ),
          );

          ThemeData darkTheme = ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: primaryColor,
              primary: primaryColor,
              secondary: secondaryColor,
              background: const Color(0xFF232323),
              surface: const Color(0xFF232323),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Colors.white,
              onSurface: Colors.white,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme,
            ).apply(bodyColor: Colors.white),
            scaffoldBackgroundColor: const Color(0xFF232323),
            appBarTheme: AppBarTheme(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: secondaryColor, width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color(0xFF232323),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: const Color(0xFF232323),
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey,
              elevation: 8,
              type: BottomNavigationBarType.fixed,
            ),
          );

          // Localization (id/en)
          Locale locale = appProvider.language == 'en' ? const Locale('en') : const Locale('id');

          return MaterialApp(
            title: 'Resep Kita',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', ''),
              Locale('id', ''),
            ],
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => MainNavigation(),
            },
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final List<Widget> _screens = [
    HomeScreen(),
    AllRecipesScreen(),
    AddEditRecipeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      body: IndexedStack(index: appProvider.selectedTabIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: appProvider.selectedTabIndex,
        onTap: (index) {
          appProvider.setTabIndex(index);
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppLocalizations.of(context)?.translate('home') ?? 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: AppLocalizations.of(context)?.translate('all_recipes') ?? 'All Recipes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: AppLocalizations.of(context)?.translate('add') ?? 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppLocalizations.of(context)?.translate('profile') ?? 'Profil'),
        ],
      ),
    );
  }
}
