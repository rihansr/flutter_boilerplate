import 'package:boilerplate/controllers/location_viewmodel.dart';
import 'package:boilerplate/models/location_model.dart';
import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  // Demo list to show querying
  List<String> searchTerms = [
    "Apple",
    "Banana",
    "Mango",
    "Pear",
    "Watermelons",
    "Blueberries",
    "Pineapples",
    "Strawberries"
  ];

  // first overwrite to
  // clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      initialData: const [],
      future: locationProvider(context: context).searchLocations(query),
      builder: (context, snapshot) => ListView.builder(
        itemCount: snapshot.data?.length,
        itemBuilder: (context, index) {
          var result = snapshot.data?[index];
          return ListTile(
            title: Text(result?.name ?? ''),
          );
        },
      ),
    );
  }

  // last overwrite to show the
  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      initialData: const [],
      future: locationProvider(context: context).searchLocations(query),
      builder: (context, snapshot) => ListView.builder(
        itemCount: snapshot.data?.length,
        itemBuilder: (context, index) {
          var result = snapshot.data?[index];
          return ListTile(
            title: Text(result?.name ?? ''),
          );
        },
      ),
    );
  }
}
