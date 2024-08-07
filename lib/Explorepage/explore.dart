import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';
import 'package:airaware/backend/data_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> _locations = [];
  DataItem? _closestStation; // Variable to store the closest station

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataProvider = Provider.of<DataProvider>(context);
    if (!dataProvider.isLoading) {
      updateMarkers(dataProvider.data ,dataProvider.closestStationData);
    }
  }

  void updateMarkers(List<dynamic> locations , DataItem? Nearest) {
    setState(() {
      _locations = locations;
       _closestStation = Nearest;

    });
    // print(_closestStation!.station);
  }

  final List<String> diseases = [
    'Asthma',
    'COPD',
    'Lung Cancer',
    'Bronchitis',
    "Emphysema",
    "Influenza",
    "Bronchiectasis",
    "Pleural effusion"
  ];

  final Map<String, int> diseaseAqiMap = {
    'Asthma': 150,
    'COPD': 100,
    'Lung Cancer': 150,
    'Bronchitis': 50,
    "Emphysema": 150,
    "Influenza": 100,
    "Bronchiectasis": 50,
    "Pleural effusion": 200
  };

  final Map<String, String> diseaseRecommendations = {
    'Asthma': 'Avoid outdoor activities and wear a mask if AQI is high.',
    'COPD': 'Stay indoors with air purifiers on high AQI days.',
    'Lung Cancer': 'Avoid areas with high pollution levels.',
    'Bronchitis': 'Minimize outdoor exposure and stay hydrated.',
    "Emphysema": 'Use air conditioning and avoid physical exertion outside.',
    "Influenza": 'Stay indoors during high pollution and ensure vaccination.',
    "Bronchiectasis": 'Keep windows closed and use air purifiers.',
    "Pleural effusion": 'Monitor AQI closely and avoid strenuous activities.'
  };

  String? selectedDisease;
  String? selectedLocation;
  int? locationAqi;
  bool? isLocationSafe;

  void checkLocationSafety() {
    if (selectedDisease != null && locationAqi != null) {
      int diseaseAqiThreshold = diseaseAqiMap[selectedDisease!]!;
      setState(() {
        isLocationSafe = locationAqi! <= diseaseAqiThreshold;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AQI Safety Checker'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check if a location is safe for your condition:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Disease',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedDisease,
                      items: diseases.map((String disease) {
                        return DropdownMenuItem<String>(
                          value: disease,
                          child: Text(disease),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDisease = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _locations
                            .map((location) => location.station as String)
                            .where((station) => station
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          selectedLocation = selection;
                        });
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Enter Location',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Dummy AQI value for the location; replace this with actual AQI lookup logic
                        setState(() {
                          locationAqi =
                              10; // For example purposes, replace with actual logic
                        });
                        checkLocationSafety();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Check Safety'),
                    ),
                    SizedBox(height: 16),
                    if (isLocationSafe != null)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isLocationSafe! ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLocationSafe!
                                  ? 'The location is safe for ${selectedDisease} conditions.'
                                  : 'The location is not safe for ${selectedDisease} conditions.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            if (selectedDisease != null)
                              Text(
                                diseaseRecommendations[selectedDisease!]!,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
