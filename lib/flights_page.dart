// ignore_for_file: library_private_types_in_public_api, unnecessary_const

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    icon: Icon(Icons.bookmark_border_outlined),
    activeIcon: Icon(Icons.bookmark_rounded),
    label: 'Flights',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline_rounded),
    activeIcon: Icon(Icons.person_rounded),
    label: 'Profile',
  ),
];

class _FlightsPageState extends State<FlightsPage> {
  List<dynamic> flights = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  // Replace with your actual API key
  final String apiKey = 'c0f413b5368a139ac89e892bb4e07f40';

  @override
  void initState() {
    super.initState();
    fetchFlights();
  }

  Future<void> fetchFlights() async {
    final response = await http.get(Uri.parse(
        'http://api.aviationstack.com/v1/flights?access_key=$apiKey'));

    if (response.statusCode == 200) {
      setState(() {
        flights = jsonDecode(response.body)['data'];
        isLoading = false;
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
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              items: _navBarItems,
              currentIndex: _selectedIndex,
              onTap: _onNavBarTapped,
            )
          : null,
      body: Row(
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
            child: _selectedIndex == 0
                ? isLoading
                    ? const Center(
                        child: FadingCircle(),
                      )
                    : ListView.builder(
                        itemCount: flights.length,
                        itemBuilder: (context, index) {
                          final flight = flights[index];
                          final departure = flight['departure'];
                          final arrival = flight['arrival'];
                          final airline = flight['airline']['name'];
                          final flightStatus = flight['flight_status'];

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
                      )
                : Center(
                    child: Text("${_navBarItems[_selectedIndex].label} Page"),
                  ),
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
                Text(
                  airline,
                  style: const TextStyle(
                    fontSize: 24,
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
            const SizedBox(height: 20),

            // Flight Number
            Text(
              'Flight Number: $flightNumber',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Departure Information
            const Text(
              'Departure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(departure['airport'], style: const TextStyle(fontSize: 16)),
            Text(departure['scheduled'],
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),

            // Arrival Information
            const Text(
              'Arrival',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(arrival['airport'], style: const TextStyle(fontSize: 16)),
            Text(arrival['scheduled'],
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
