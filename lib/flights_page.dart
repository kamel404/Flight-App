// ignore_for_file: library_private_types_in_public_api, unnecessary_const, prefer_const_constructors, use_key_in_widget_constructors, non_constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});

  @override
  _FlightsPageState createState() => _FlightsPageState();
}

const _navBarItems = [
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
];

class _FlightsPageState extends State<FlightsPage> {
  List<dynamic> flights = [];
  bool isLoading = true;
  int _selectedIndex = 0; // Default page
  bool autoRefresh = true; // Auto-refresh toggle
  String lastUpdated = ""; // Timestamp for last update
  final String apiKey = '36443575b2e7771dae76b69fd7f5d165';

  @override
  void initState() {
    super.initState();
    _loadAutoRefreshSetting(); // Load setting when initializing
    fetchFlights();
    if (autoRefresh) {
      _startAutoRefresh();
    }
  }

  // Load the auto-refresh setting from shared preferences
  Future<void> _loadAutoRefreshSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      autoRefresh = prefs.getBool('autoRefresh') ?? true; // Default to true
    });
    if (autoRefresh) {
      _startAutoRefresh();
    }
  }

  // Toggle auto-refresh and save preference
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

  // Method to start auto-refresh
  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: 10), () {
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

    final response = await http.get(Uri.parse(
        'http://api.aviationstack.com/v1/flights?access_key=$apiKey'));

    if (response.statusCode == 200) {
      setState(() {
        flights = jsonDecode(response.body)['data'];
        isLoading = false;
        lastUpdated = DateTime.now().toString().substring(11, 19);
      });
    } else {
      throw Exception('Failed to load flights');
    }
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 600;
    final bool isLargeScreen = width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navBarItems,
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
      ),
      body: RefreshIndicator(
        onRefresh: fetchFlights, // Manual refresh on swipe down
        child: Row(
          children: <Widget>[
            if (!isSmallScreen)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                extended: isLargeScreen,
                destinations: _navBarItems
                    .map((item) => NavigationRailDestination(
                        icon: item.icon,
                        selectedIcon: item.activeIcon,
                        label: Text(item.label!)))
                    .toList(),
              ),
            const VerticalDivider(thickness: 1, width: 1),
            // Main content area
            Expanded(
              child: _selectedIndex == 0 // Home page index
                  ? HomePage()
                  : _selectedIndex == 1
                      ? isLoading
                          ? const Center(
                              child: FadingCircle(),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Last Updated: $lastUpdated',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: flights.length,
                                    itemBuilder: (context, index) {
                                      final flight = flights[index];
                                      final departure = flight['departure'];
                                      final arrival = flight['arrival'];
                                      final airline = flight['airline']['name'];
                                      final flightStatus =
                                          flight['flight_status'];

                                      return FlightCard(
                                        flight: flight,
                                        airline: airline,
                                        departureAirport: departure['airport'],
                                        departureTime: departure['scheduled'],
                                        arrivalAirport: arrival['airport'],
                                        arrivalTime: arrival['scheduled'],
                                        flightStatus: flightStatus,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                      : _selectedIndex == 2 // Settings page index
                          ? SettingsPage(
                              autoRefresh: autoRefresh,
                              toggleAutoRefresh: _toggleAutoRefresh,
                            )
                          : Center(
                              child: Text(
                                  "${_navBarItems[_selectedIndex].label} Page"),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Flight Tracker',
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 10),
              Text(
                'Your ultimate tool for monitoring flights in real-time. Stay updated and travel smart!',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 10),
                    _featureTile('Real-time flight updates', Icons.access_time),
                    _featureTile('Detailed flight information', Icons.info),
                    _featureTile('User-friendly interface', Icons.touch_app),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Lorem Ipsum:',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Image.asset(
                    'flightImage.jpg',
                    // fit: BoxFit.fill,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureTile(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// New Flights List Widget
class FlightsList extends StatelessWidget {
  final List<dynamic> flights;
  final String lastUpdated;

  const FlightsList(
      {super.key, required this.flights, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Last Updated: $lastUpdated',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];

              // Use null-aware operators (??) to provide default values for null fields
              final departure = flight['departure'] ?? {};
              final arrival = flight['arrival'] ?? {};
              final airline = flight['airline']?['name'] ?? 'Unknown Airline';
              final flightStatus =
                  flight['flight_status'] ?? 'Status Unavailable';

              final departureAirport =
                  departure['airport'] ?? 'Unknown Departure Airport';
              final departureTime = departure['scheduled'] ?? 'N/A';
              final arrivalAirport =
                  arrival['airport'] ?? 'Unknown Arrival Airport';
              final arrivalTime = arrival['scheduled'] ?? 'N/A';

              return FlightCard(
                flight: flight,
                airline: airline,
                departureAirport: departureAirport,
                departureTime: departureTime,
                arrivalAirport: arrivalAirport,
                arrivalTime: arrivalTime,
                flightStatus: flightStatus,
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  final bool autoRefresh;
  final VoidCallback toggleAutoRefresh;
  final Uri flutterUrl = Uri.parse('https://flutter.dev');
  final Uri GithubUrl = Uri.parse('https://github.com/kamel404');

  SettingsPage({
    super.key,
    required this.autoRefresh,
    required this.toggleAutoRefresh,
  });

  Future<void> _launchFlutterWebsite() async {
    if (await canLaunchUrl(flutterUrl)) {
      await launchUrl(flutterUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $flutterUrl';
    }
  }

  Future<void> _launchMyGithub() async {
    if (await canLaunchUrl(GithubUrl)) {
      await launchUrl(GithubUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $flutterUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text('Auto Refresh'),
            value: autoRefresh,
            onChanged: (value) {
              toggleAutoRefresh();
            },
          ),
          ListTile(
            title: Text('Visit Flutter Official Website'),
            trailing: Icon(Icons.open_in_new),
            onTap: _launchFlutterWebsite,
          ),
          ListTile(
            title: Text('Visit My Github'),
            trailing: Icon(Icons.open_in_new),
            onTap: _launchMyGithub,
          ),
        ],
      ),
    );
  }
}

class FadingCircle extends StatefulWidget {
  const FadingCircle({super.key});

  @override
  _FadingCircleState createState() => _FadingCircleState();
}

class _FadingCircleState extends State<FadingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}

class FlightCard extends StatelessWidget {
  final dynamic flight;
  final String airline;
  final String departureAirport;
  final String departureTime;
  final String arrivalAirport;
  final String arrivalTime;
  final String flightStatus;

  const FlightCard({
    super.key,
    required this.flight,
    required this.airline,
    required this.departureAirport,
    required this.departureTime,
    required this.arrivalAirport,
    required this.arrivalTime,
    required this.flightStatus,
  });

  @override
  Widget build(BuildContext context) {
    // Color coding for flight status
    Color statusColor;
    switch (flightStatus.toLowerCase()) {
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'active':
        statusColor = Colors.green;
        break;
      case 'landed':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Airline and Flight Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  airline,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    flightStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Departure and Arrival Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Departure',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(departureAirport,
                          style: const TextStyle(fontSize: 16)),
                      Text(departureTime,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Arrival',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(arrivalAirport,
                          style: const TextStyle(fontSize: 16)),
                      Text(arrivalTime,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Button to view details
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.info_outline),
                label: const Text('Details'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlightDetailPage(flight: flight),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlightDetailPage extends StatelessWidget {
  final dynamic flight;

  const FlightDetailPage({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    final departure = flight['departure'];
    final arrival = flight['arrival'];
    final airline = flight['airline']['name'];
    final flightStatus = flight['flight_status'];
    final flightNumber = flight['flight']['iata'];

    // Color coding for flight status
    Color statusColor;
    switch (flightStatus.toLowerCase()) {
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'active':
        statusColor = Colors.green;
        break;
      case 'landed':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Details'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Airline and Flight Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        airline,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flight Number: $flightNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    flightStatus.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Departure Information
            _buildFlightInfoSection('Departure Information', departure),
            const SizedBox(height: 20),

            // Arrival Information
            _buildFlightInfoSection('Arrival Information', arrival),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfoSection(String title, Map<String, dynamic> info) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Departure Airport
                _buildFlightDetailCard(
                  Icons.airport_shuttle,
                  info['airport'],
                  'Airport',
                ),
                // Scheduled Time
                _buildFlightDetailCard(
                  Icons.schedule,
                  info['scheduled'],
                  'Scheduled',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Additional Info (e.g., Gate, Terminal)
            Text(
              'Gate: ${info['gate'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Terminal: ${info['terminal'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightDetailCard(IconData icon, String detail, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
