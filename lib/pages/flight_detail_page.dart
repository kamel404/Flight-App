import 'package:flutter/material.dart';

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
                        overflow: TextOverflow.ellipsis, // Handle overflow
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flight Number: $flightNumber',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow
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
          overflow: TextOverflow.ellipsis, // Handle overflow
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
