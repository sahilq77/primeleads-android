import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/view/home/home_screen.dart';

import '../../controller/location/location_controller.dart';
import '../../controller/location/minmax_city_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../controller/subscription/buy_subscription_controller.dart';
import '../../utility/app_colors.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  _LocationSelectionScreenState createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final LocationController controller = Get.put(LocationController());
  final TextEditingController _searchController = TextEditingController();
  final MinmaxCityController minmaxcontroller = Get.put(MinmaxCityController());
  final BuySubscriptionController buyController = Get.put(
    BuySubscriptionController(),
  );
  final ProfileController profileController = Get.put(ProfileController());

  String? selectedState;
  final List<String> selectedCities = [];

  @override
  void initState() {
    super.initState();
    // Listen to search input changes to trigger UI rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchUserProfile(context: Get.context!);
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleCitySelection(String city) {
    // Safely parse maxValue
    int maxValue = 0;
    try {
      if (minmaxcontroller.maxValue.value != null &&
          minmaxcontroller.maxValue.value.isNotEmpty) {
        maxValue = int.parse(minmaxcontroller.maxValue.value);
      }
    } catch (e) {
      print('Error parsing maxValue: $e');
      return; // Or set a default maxValue to a reasonable default (e.g., 5)
    }
    setState(() {
      if (selectedCities.contains(city)) {
        selectedCities.remove(city);
      } else if (selectedCities.length < maxValue) {
        selectedCities.add(city);
      }
    });
  }

  List<String> _getFilteredCities() {
    final query = _searchController.text.toLowerCase();
    final allCities = controller.getCityNames(
      controller.selectedStateName?.value,
    );

    if (query.isEmpty) {
      return allCities;
    }
    return allCities
        .where((city) => city.toLowerCase().contains(query))
        .toList();
  }

  Future<void> onRefresh(BuildContext context) async {
    // Clear local state before fetching new data
    minmaxcontroller.minmaxList.clear();
    controller.stateList.value.clear();
    selectedCities.clear();
    _getFilteredCities().clear();

    // Await data fetching
    await minmaxcontroller.fetchCategory(context: context, isRefresh: true);
    await controller.fetchSectorLocations(context: context, isRefresh: true);

    // Trigger UI update if needed
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Select Location',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Divider(
            color: const Color(0xFFDADADA),
            thickness: 2,
            height: 0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => onRefresh(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Find your leads' target city.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              Obx(
                () =>
                    minmaxcontroller.minValue.value.isEmpty &&
                            minmaxcontroller.minValue.value.isEmpty
                        ? Text("")
                        : Text(
                          'Identify at least ${minmaxcontroller.minValue} and up to  ${minmaxcontroller.maxValue} cities that are of the greatest interest to your potential customers.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Obx(() {
                return Column(
                  children: [
                    // State Dropdown
                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search State',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      items: controller.getStateNames(),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: 'Select State',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          controller.updateSelectedState(value);
                          selectedCities
                              .clear(); // Clear selected cities when state changes
                          _searchController.clear(); // Clear search query
                        });
                      },
                      selectedItem: controller.selectedStateName?.value,
                    ),
                  ],
                );
              }),
              SizedBox(height: screenHeight * 0.02),
              // Search TextField for Recommended Cities
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Recommended Cities',
                  suffixIcon: Icon(Icons.search, color: AppColors.primaryTeal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Selected Cities as Chips
              Wrap(
                spacing: 8.0,
                children:
                    selectedCities.map((city) {
                      return Chip(
                        shape: StadiumBorder(
                          side: BorderSide(color: AppColors.primaryTeal),
                        ),
                        label: Text(city, style: const TextStyle(fontSize: 13)),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _toggleCitySelection(city),
                        backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                      );
                    }).toList(),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Recommended Cities',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: screenHeight * 0.01),
              controller.selectedStateName == null
                  ? const Center(child: Text('Please select a state first'))
                  : _getFilteredCities().isEmpty
                  ? const Center(child: Text('No cities found'))
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _getFilteredCities().length,
                    itemBuilder: (context, index) {
                      final city = _getFilteredCities()[index];
                      final isSelected = selectedCities.contains(city);
                      return Card(
                        color: isSelected ? primaryTeal.withOpacity(0.1) : null,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(city),
                          onTap: () => _toggleCitySelection(city),
                        ),
                      );
                    },
                  ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Safely parse minValue
              int minValue = 0;
              try {
                if (minmaxcontroller.minValue != null &&
                    minmaxcontroller.minValue.value != null &&
                    minmaxcontroller.minValue.isNotEmpty) {
                  minValue = int.parse(minmaxcontroller.minValue.value);
                }
              } catch (e) {
                print('Error parsing minValue: $e');
                return null;
                // Disable button if minValue is invalid
              }
              return selectedCities.length >= minValue &&
                      controller.selectedStateName?.value != null
                  ? () {
                    log('Selected Cities: $selectedCities');
                    log(
                      'Selected State ID: ${controller.selectedStateId?.value}',
                    );
                    log(
                      'Selected City IDs: ${selectedCities.map((city) => controller.getCityId(city)).toList()}',
                    );
                    // Add navigation or API call here
                    final args = Get.arguments;
                    final subid = args['subscription_id'] as String;
                    final tranID = args['transaction'] as String;
                    // final subUserID = args['subscribed_user_id'] as String;
                    log('subscription_id: $subid');
                    log('transaction_id: $tranID');
                    buyController.submitSubscription(
                      subscriptionid: subid,
                      subscriptionUserId: "",
                      context: context,
                      stateID: controller.selectedStateId?.value,
                      cityID:
                          selectedCities
                              .map((city) => controller.getCityId(city))
                              .toList(),
                      transactionID: tranID,
                    );
                  }
                  : null;
            }(),
            child: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
