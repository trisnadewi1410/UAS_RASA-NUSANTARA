import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/all_recipes_screen.dart';
import 'screens/add_edit_recipe_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'helpers/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
          final Color seedColor = Color(0xFF7B3F00);
          final Color primaryColor = seedColor;
          final Color secondaryColor = Color(0xFFE07A5F);
          final Color backgroundColor = Color(0xFFF5E9DA);
          final double fontSize = appProvider.fontSize;

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
              Theme.of(context).textTheme.apply(fontSizeFactor: fontSize / 14.0),
            ).apply(bodyColor: Color(0xFF3E2723)),
            scaffoldBackgroundColor: backgroundColor,
            fontFamily: 'Roboto',
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF7B3F00),
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
              fillColor: Color(0xFFF9F6F2),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF7B3F00),
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
              background: Color(0xFF232323),
              surface: Color(0xFF232323),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Colors.white,
              onSurface: Colors.white,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData.dark().textTheme.apply(fontSizeFactor: fontSize / 14.0),
            ).apply(bodyColor: Colors.white),
            scaffoldBackgroundColor: Color(0xFF232323),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF7B3F00),
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
              fillColor: Color(0xFF2C2C2C),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Color(0xFF232323),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF232323),
              selectedItemColor: Color(0xFFFFAB91),
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
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AllRecipesScreen(),
    AddEditRecipeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Color(0xFF7B3F00),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: AppLocalizations.of(context)?.translate('home') ?? 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: AppLocalizations.of(context)?.translate('all_recipes') ?? 'All Recipes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: AppLocalizations.of(context)?.translate('add') ?? 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppLocalizations.of(context)?.translate('profile') ?? 'Profile'),
        ],
      ),
    );
  }
}
