# Project Documentation: Flights App
## Overview
The Flights App is a Flutter application that fetches flight data from the AviationStack API and displays it in a user-friendly interface. Users can filter flights by departure and arrival airports and toggle an auto-refresh feature to keep the flight data updated.

## Prerequisites
Before setting up the project, ensure you have the following installed on your machine:

- Flutter SDK: Follow the Flutter installation guide for your operating system.
- Dart SDK: The Dart SDK is included with Flutter, but ensure you have the latest version.
- An IDE: Recommended IDEs include Android Studio, Visual Studio Code, or IntelliJ IDEA with Flutter and Dart plugins.
- AviationStack API Key: Sign up at AviationStack to obtain an API key.

## Project Setup
### 1- Clone the Repository:

```
git clone 'https://github.com/kamel404/Flight-App.git'
cd <repository-directory>
```

### 2- Install Dependencies: Navigate to the project directory and run:
```
flutter pub get
```

### 3- Configure the API Key: Open the FlightsPage class in flights_page.dart and replace the placeholder API key with your actual AviationStack API key:
```
final String apiKey = 'get_aviation_api_key';
```
### 4- Run the Application: Ensure you have an emulator running or a physical device connected. Then, execute:
```
flutter run
```

## Project Structure

- lib/: Contains all the Dart code for the application.
  - main.dart: Entry point of the application.
  - flights_page.dart: Contains the FlightsPage widget which handles fetching and displaying flight data.
  - home_page.dart: Home page widget displayed when the user selects the home tab.
  - settings_page.dart: Contains the settings page where users can toggle auto-refresh.
  - widgets/: Contains reusable widgets like FlightsList.


## Features

- Flight Data Fetching: The app fetches flight data from the AviationStack API.
- Filtering: Users can filter flights based on selected departure and arrival airports.
- Auto-Refresh: The app can automatically refresh flight data at a specified interval.
- User Interface: A clean and responsive UI that adapts to different screen sizes.

## Key Components
- State Management: The application uses Flutter's built-in state management via StatefulWidget to manage the state of the flight data and UI.
- HTTP Requests: The app uses the http package to make network requests to the AviationStack API.
- Shared Preferences: The app uses the shared_preferences package to store user preferences (like auto-refresh settings).

## Troubleshooting
### Common Issues:
- If you encounter issues with network requests, ensure your API key is valid and that you have a stable internet connection.
- Check for any errors in the console output for more specific debugging information.

## Conclusion
You are now set up to run and develop the Flights App. If you have any questions or need further assistance, feel free to reach out to the original developers or consult the Flutter documentation. Happy coding!
