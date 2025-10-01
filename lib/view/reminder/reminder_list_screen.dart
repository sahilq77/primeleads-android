import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_leads/controller/lead_list_controller.dart';
import 'package:prime_leads/controller/reminder_list/reminder_list_controller.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/leads/get_leads_controller.dart';
import '../../utility/nodatascreen.dart';
import '../bottomnavgation/bottom_navigation.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  final bottomController = Get.put(BottomNavigationController());
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _reminderdateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final controller = Get.put(ReminderListController());
  DateTime _selectedDate = DateTime.now(); // Use today's date
  DateTime _selectedReminderDate = DateTime.now(); // Separate date for reminder
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = true;
  String? date;

  @override
  void initState() {
    super.initState();
    final rdate = Get.arguments as String;
    setState(() {
      date = rdate;
    });

    if (date != null && date != "") {
      controller.fetchReminderList(context: context, date: date);
    }
    // Initialize date controllers with today's date
    _dateController.text =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    _reminderdateController.text =
        "${_selectedReminderDate.day}/${_selectedReminderDate.month}/${_selectedReminderDate.year}";
    print(
      'Initial _dateController.text: ${_dateController.text}',
    ); // Debug print
    print(
      'Initial _reminderdateController.text: ${_reminderdateController.text}',
    ); // Debug print

    // Simulate loading delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize time controller with formatted time
    _timeController.text = _selectedTime.format(context);
  }

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
        print('Filter date updated: ${_dateController.text}'); // Debug print
      });
    }
  }

  String formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  Future<void> _selectReminderDate(
    BuildContext context,
    StateSetter setState,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedReminderDate) {
      setState(() {
        _selectedReminderDate = picked;
        _reminderdateController.text =
            "${_selectedReminderDate.day}/${_selectedReminderDate.month}/${_selectedReminderDate.year}";
        print(
          'Reminder date updated: ${_reminderdateController.text}',
        ); // Debug print
      });
    }
  }

  Future<void> _selectTime(BuildContext context, StateSetter setState) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = _selectedTime.format(context);
        print('Time updated: ${_timeController.text}'); // Debug print
      });
    }
  }

  _makingPhoneCall(String num) async {
    var _url = Uri.parse("tel:$num");
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    String phoneNumber,
    String message,
  ) async {
    // Ensure phone number starts with '+' and is in international format
    if (!phoneNumber.startsWith('+')) {
      phoneNumber =
          '+$phoneNumber'; // Add country code if missing (modify as needed)
    }

    // Remove any spaces or special characters from phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Encode the message for URL
    final String encodedMessage = Uri.encodeComponent(message);
    final String whatsappUrl =
        'https://wa.me/$phoneNumber?text=$encodedMessage';

    // Create URI object
    final Uri uri = Uri.parse(whatsappUrl);

    try {
      // Check if the URL can be launched
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in WhatsApp app
        );
      } else {
        // Show error if WhatsApp is not installed or URL is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WhatsApp is not installed or the phone number is invalid',
            ),
          ),
        );
      }
    } catch (e) {
      // Log the error and show user feedback
      debugPrint('Error launching WhatsApp: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  void _clearDate() {
    setState(() {
      _dateController.clear();
      print('Filter date cleared'); // Debug print
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreResults(context: context);
      }
    });

    // Function to format the date for the API
    String? formatDateForApi(String? inputDate) {
      if (inputDate == null || inputDate.isEmpty) return null;
      try {
        final parts = inputDate.split('/');
        if (parts.length != 3) return null;
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final dateTime = DateTime(year, month, day);
        return DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        print('Error formatting date: $e');
        return null;
      }
    }

    String formatDate(String inputDate) {
      DateTime dateTime = DateTime.parse(inputDate);
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(dateTime);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Reminder List',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(color: Color(0xFFDADADA), thickness: 2, height: 0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Pass the formatted date from _dateController
          await controller.refreshleadsList(context: context, date: date);
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return CustomShimmer(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            );
          }

          return ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount:
                controller.leadsList.isEmpty
                    ? 1
                    : controller.leadsList.length +
                        (controller.hasMoreData.value ||
                                controller.isLoadingMore.value
                            ? 1
                            : 0),
            itemBuilder: (context, int index) {
              if (controller.leadsList.isEmpty) {
                return NoDataScreen();
              }

              if (index == controller.leadsList.length) {
                return controller.isLoadingMore.value
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No more data',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.defaultblack,
                          ),
                        ),
                      ),
                    );
              }

              var lead = controller.leadsList[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Name", "${lead.name}"),

                      _buildDetailRow("Contact No.", "${lead.mobileNo}"),

                      _buildDetailRow(
                        "Date",
                        "${formatDate(lead.date.toString())}",
                      ),
                      _buildDetailRow("Time", "${lead.reminderTime}"),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _cardBottomButtons(
                            screenWidth,
                            color: 0xFF7294EA,
                            icon: AppImages.callIcon,
                            title: "Call",
                            press: () {
                              _makingPhoneCall(lead.mobileNo);
                            },
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          _cardBottomButtons(
                            screenWidth,
                            color: 0xFF36CAA8,
                            icon: AppImages.whatsapplIcon,
                            title: "Whatsapp",
                            press: () {
                              _launchWhatsApp(
                                context,
                                lead.whatsappNo,
                                "Hello",
                              );
                            },
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          _cardBottomButtons(
                            screenWidth,
                            color: 0xFFCA9636,
                            icon: AppImages.noteIcon,
                            title: "Note",
                            press: () {
                              _noteDialog(context, controller, lead.id);
                              setState(() {
                                _noteController.text = lead.note;
                              });
                            },
                          ),
                          // Uncomment and fix the reminder button if needed
                          // _cardBottomButtons(
                          //   screenWidth,
                          //   color: 0xFFCA4236,
                          //   icon: AppImages.reminderIcon,
                          //   title: "Reminder",
                          //   press: () {
                          //     _reminderDialog(
                          //       context,
                          //       controller,
                          //       _selectedReminderDate.toString(),
                          //       _selectedTime.toString(),
                          //       lead.id,
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        child:
                            lead.note != "" && lead.note != null
                                ? Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: const Color(
                                      0xff7d5db71f,
                                    ).withOpacity(0.1),
                                  ),
                                  child: Text(
                                    'Note: ${lead.note}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                                : SizedBox(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Color(0xFF39373C),
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ':  $value',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Color(0xFF39373C),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _noteDialog(
    BuildContext context,
    ReminderListController controller,
    String id,
  ) {
    return showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Leave a Note',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _noteController,
                          maxLines: 4,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Type here',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                controller.updateNote(
                                  context: context,
                                  id: id,
                                  note: _noteController.text.trim(),
                                );

                                print(_noteController.text.trim());
                                _noteController.clear();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'No Thanks!',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  _reminderDialog(
    BuildContext context,
    ReminderListController controller,
    String date,
    String time,
    String id,
  ) {
    return showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Your Availability',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _reminderdateController,
                          decoration: InputDecoration(
                            labelText: 'Select Date',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed:
                                  () => _selectReminderDate(context, setState),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _timeController,
                          decoration: InputDecoration(
                            labelText: 'Select Time',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () => _selectTime(context, setState),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                String formatDate(String inputDate) {
                                  DateTime dateTime = DateTime.parse(inputDate);
                                  DateFormat formatter = DateFormat(
                                    'yyyy-MM-dd',
                                  );
                                  return formatter.format(dateTime);
                                }

                                controller.setReminder(
                                  id: id,
                                  rdate: formatDate(
                                    _selectedReminderDate.toString(),
                                  ),
                                  rtime: _timeController.text.trim(),
                                );
                                print(
                                  formatDate(_selectedReminderDate.toString()),
                                );
                                print(_timeController.text.trim());
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Set Reminder',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'No Thanks!',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  _cardBottomButtons(
    double screenWidth, {
    required color,
    required String icon,
    required String title,
    required VoidCallback press,
  }) {
    return GestureDetector(
      onTap: press,
      child: Container(
        height: 30,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Color(color)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(icon),
              SizedBox(width: screenWidth * 0.01),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF39373C),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomShimmer extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const CustomShimmer({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(const Duration(seconds: 2));
      },
      child: ListView.builder(
        itemCount: 4,
        itemBuilder:
            (context, index) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade100, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 200, height: 16, color: Colors.white),
                      SizedBox(height: screenHeight * 0.01),
                      Container(width: 150, height: 16, color: Colors.white),
                      SizedBox(height: screenHeight * 0.01),
                      Container(width: 100, height: 16, color: Colors.white),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          4,
                          (index) => Container(
                            width: screenWidth * 0.2,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
