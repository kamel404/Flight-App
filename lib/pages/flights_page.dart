// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/flights_list.dart';
import 'home_page.dart';
import 'settings_page.dart';
import '../widgets/fading_circle.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  List<dynamic> flights = [];
  bool isLoading = true;
  int _selectedIndex = 0;
  bool autoRefresh = true;
  String lastUpdated = "";
  final String apiKey = 'a74f970d156624d7ac9c18c172f3dc1c';

  @override
  void initState() {
    super.initState();
    _loadAutoRefreshSetting();
    fetchFlights();
    if (autoRefresh) {
      _startAutoRefresh();
    }
  }

  Future<void> _loadAutoRefreshSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      autoRefresh = prefs.getBool('autoRefresh') ?? true; // Default to true
    });
    if (autoRefresh) {
      _startAutoRefresh();
    }
  }

  void _toggleAutoRefresh() async {
    setState(() {
      autoRefresh = !autoRefresh;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('autoRefresh', autoRefresh);
      });
      if (autoRefresh) {
        _startAutoRefresh();
      }
    });
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 10), () {
      if (autoRefresh) {
        fetchFlights();
        _startAutoRefresh();
      }
    });
  }

  Future<void> fetchFlights() async {
    setState(() {
      isLoading = true; // Set loading state
    });

    try {
      final response = await http.get(Uri.parse(
          'http://api.aviationstack.com/v1/flights?access_key=$apiKey'));

      if (response.statusCode == 200) {
        setState(() {
          flights = jsonDecode(response.body)['data'] ?? [];
          isLoading = false;
          lastUpdated = DateTime.now().toString().substring(11, 19);
        });
      } else {
        _showErrorSnackbar('Failed to load flights: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar('Error: $e');
    }
  }

// Method to show error Snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     // title: const Text('Flights'),
      //     ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_land_rounded),
            activeIcon: Icon(Icons.flight_land_rounded),
            label: 'Flights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
      ),
      body: RefreshIndicator(
        onRefresh: fetchFlights,
        child: Row(
          children: <Widget>[
            if (MediaQuery.of(context).size.width > 600)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                extended: MediaQuery.of(context).size.width > 800,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.flight_land_rounded),
                    selectedIcon: Icon(Icons.flight_land_rounded),
                    label: Text('Flights'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings),
                    selectedIcon: Icon(Icons.settings),
                    label: Text('Settings'),
                  ),
                ],
              ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _selectedIndex == 0
                  ? const HomePage()
                  : _selectedIndex == 1
                      ? isLoading
                          ? const Center(
                              child: FadingCircle(),
                            )
                          : FlightsList(
                              flights: flights,
                              lastUpdated: lastUpdated,
                            )
                      : _selectedIndex == 2
                          ? SettingsPage(
                              autoRefresh: autoRefresh,
                              toggleAutoRefresh: _toggleAutoRefresh,
                            )
                          : Center(
                              child: Text("$_selectedIndex Page"),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
