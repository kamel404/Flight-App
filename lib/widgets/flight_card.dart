import 'package:flutter/material.dart';

import '../pages/flight_detail_page.dart';

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
