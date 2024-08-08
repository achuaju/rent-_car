import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarListProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedSortOption = 'Price: Low to High';

  String get searchQuery => _searchQuery;
  String get selectedSortOption => _selectedSortOption;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSortOption(String option) {
    _selectedSortOption = option;
    notifyListeners();
  }

  Query get sortedQuery {
    CollectionReference carsCollection = FirebaseFirestore.instance.collection('cars');
    switch (_selectedSortOption) {
      case 'Price: Low to High':
        return carsCollection.orderBy('price', descending: false);
      case 'Price: High to Low':
        return carsCollection.orderBy('price', descending: true);
      case 'Newest First':
        return carsCollection.orderBy('timestamp', descending: true);
      case 'Oldest First':
        return carsCollection.orderBy('timestamp', descending: false);
      default:
        return carsCollection;
    }
  }

  List<DocumentSnapshot> filterCars(List<DocumentSnapshot> docs) {
    return docs.where((doc) {
      var carData = doc.data() as Map<String, dynamic>;
      var carName = '${carData['brand']} ${carData['model']}';
      return carName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
}
