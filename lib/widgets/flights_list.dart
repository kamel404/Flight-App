import 'package:flutter/material.dart';

import 'flight_card.dart';

class FlightsList extends StatelessWidget {
  final List<dynamic> flights;
  final String lastUpdated;

  const FlightsList({
    super.key,
    required this.flights,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final flight = flights[index];
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
