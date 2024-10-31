// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/flights_list.dart';
import 'home_page.dart';
import 'settings_page.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  List<dynamic> flights = [];
  List<String> departureAirports = [];
  List<String> arrivalAirports = [];
  String? selectedDeparture;
  String? selectedArrival;
  bool isLoading = true;
  int _selectedIndex = 0;
  bool autoRefresh = true;
  String lastUpdated = "";
  final String apiKey = '2ff44ce9c93d999bec9cf72e8ab75b53';

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
      autoRefresh = prefs.getBool('autoRefresh') ?? true;
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
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://api.aviationstack.com/v1/flights?access_key=$apiKey'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] ?? [];
        setState(() {
          flights = data;
          lastUpdated = DateTime.now().toString().substring(11, 19);
          isLoading = false;

          // Safely extract departure and arrival airports
          departureAirports = data
              .map((flight) => flight['departure']?['airport'])
              .where((airport) => airport != null)
              .toSet()
              .toList()
              .cast<String>();
          arrivalAirports = data
              .map((flight) => flight['arrival']?['airport'])
              .where((airport) => airport != null)
              .toSet()
              .toList()
              .cast<String>();
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedDeparture = null;
      selectedArrival = null;
    });
  }

  List<dynamic> _filterFlights() {
    return flights.where((flight) {
      final departureMatch = selectedDeparture == null ||
          flight['departure']?['airport'] == selectedDeparture;
      final arrivalMatch = selectedArrival == null ||
          flight['arrival']?['airport'] == selectedArrival;
      return departureMatch && arrivalMatch;
    }).toList();
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              child: CircularProgressIndicator(),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title with Icon
                                          const Row(
                                            children: [
                                              Icon(Icons.filter_list,
                                                  color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text(
                                                'Filter Flights',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          // Departure Airport Dropdown
                                          const Text('Departure Airport',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                            ),
                                            hint: const Text(
                                                "Select Departure Airport"),
                                            value: selectedDeparture,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedDeparture = value;
                                              });
                                            },
                                            items: departureAirports
                                                .map((airport) =>
                                                    DropdownMenuItem(
                                                      value: airport,
                                                      child: Text(airport),
                                                    ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 16),

                                          // Arrival Airport Dropdown
                                          const Text('Arrival Airport',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                            ),
                                            hint: const Text(
                                                "Select Arrival Airport"),
                                            value: selectedArrival,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedArrival = value;
                                              });
                                            },
                                            items: arrivalAirports
                                                .map((airport) =>
                                                    DropdownMenuItem(
                                                      value: airport,
                                                      child: Text(airport),
                                                    ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 24),

                                          // Divider Line
                                          const Divider(thickness: 1),

                                          // Reset Button and Last Updated Time
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: _resetFilters,
                                                icon: const Icon(Icons.refresh,
                                                    size: 18),
                                                label:
                                                    const Text('Reset Filters'),
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Last Updated: $lastUpdated',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FlightsList(
                                    flights: _filterFlights(),
                                    lastUpdated: lastUpdated,
                                  ),
                                ),
                              ],
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
