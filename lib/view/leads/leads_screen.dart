// lib/view/leads/leads_screen.dart
import 'dart:developer' as lg;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/nodatascreen.dart';
import 'package:prime_leads/view/reminder_notification.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/bottomnavigation/bottom_navigation_controller.dart';
import '../../controller/leads/get_leads_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../core/db_helper.dart';
import '../../utility/app_routes.dart';
import '../bottomnavgation/bottom_navigation.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final profileController = Get.put(ProfileController());
  List<Map<String, dynamic>> _reminders = [];
  final bottomController = Get.put(BottomNavigationController());
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _reminderdateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final controller = Get.put(GetLeadsController());
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedReminderDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    ReminderNotification().init();
    _requestPermissions();
    _dateController.text =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    _reminderdateController.text =
        "${_selectedReminderDate.day}/${_selectedReminderDate.month}/${_selectedReminderDate.year}";
    lg.log(
      'Initial _dateController.text: ${_dateController.text}',
      time: DateTime.now(),
    );
    lg.log(
      'Initial _reminderdateController.text: ${_reminderdateController.text}',
      time: DateTime.now(),
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _requestPermissions() async {
    PermissionStatus notificationStatus =
        await Permission.notification.request();
    if (notificationStatus.isDenied || notificationStatus.isPermanentlyDenied) {
      lg.log(
        'LeadsScreen: Notification permission denied',
        time: DateTime.now(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification permission is required. Please enable it in settings.',
          ),
        ),
      );
      await openAppSettings();
    } else {
      lg.log(
        'LeadsScreen: Notification permission granted',
        time: DateTime.now(),
      );
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
      lg.log(
        'LeadsScreen: SCHEDULE_EXACT_ALARM permission requested',
        time: DateTime.now(),
      );
    }

    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
      lg.log(
        'LeadsScreen: Battery optimization exemption requested',
        time: DateTime.now(),
      );
    }
  }

  Future<void> _deleteReminder(int id) async {
    await _dbHelper.deleteReminder(id);
    await ReminderNotification().cancelNotification(id);
    lg.log('LeadsScreen: Deleted reminder with ID: $id', time: DateTime.now());
  }

  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
        lg.log(
          'LeadsScreen: Filter date updated: ${_dateController.text}',
          time: DateTime.now(),
        );
      });
    }
  }

  Future<void> _selectReminderDate(
    BuildContext context,
    StateSetter setState,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedReminderDate) {
      setState(() {
        _selectedReminderDate = picked;
        _reminderdateController.text =
            "${_selectedReminderDate.day}/${_selectedReminderDate.month}/${_selectedReminderDate.year}";
        lg.log(
          'LeadsScreen: Reminder date updated: ${_reminderdateController.text}',
          time: DateTime.now(),
        );
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
        lg.log(
          'LeadsScreen: Time updated: ${_timeController.text}',
          time: DateTime.now(),
        );
      });
    }
  }

  _makingPhoneCall(String num) async {
    var _url = Uri.parse("tel:$num");
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      lg.log(
        'LeadsScreen: Could not launch phone call: $_url',
        time: DateTime.now(),
      );
      throw Exception('Could not launch $_url');
    }
    lg.log('LeadsScreen: Initiated phone call to $num', time: DateTime.now());
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    String phoneNumber,
    String message,
  ) async {
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+$phoneNumber';
    }
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final String encodedMessage = Uri.encodeComponent(message);
    final String whatsappUrl =
        'https://wa.me/$phoneNumber?text=$encodedMessage';
    final Uri uri = Uri.parse(whatsappUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        lg.log(
          'LeadsScreen: Launched WhatsApp for $phoneNumber',
          time: DateTime.now(),
        );
      } else {
        lg.log(
          'LeadsScreen: WhatsApp not installed or invalid phone number: $phoneNumber',
          time: DateTime.now(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WhatsApp is not installed or the phone number is invalid',
            ),
          ),
        );
      }
    } catch (e) {
      lg.log('LeadsScreen: Error launching WhatsApp: $e', time: DateTime.now());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  void _clearDate() {
    setState(() {
      _dateController.clear();
      lg.log('LeadsScreen: Filter date cleared', time: DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreResults(context: context);
      }
    });
    return WillPopScope(
      onWillPop: () async {
        lg.log(
          'LeadsScreen: WillPopScope triggered, current route: ${Get.currentRoute}, selectedIndex: ${bottomController.selectedIndex.value}',
          time: DateTime.now(),
        );
        if (Get.currentRoute != AppRoutes.home &&
            Get.currentRoute != AppRoutes.splash) {
          lg.log('LeadsScreen: Navigating to home', time: DateTime.now());
          bottomController.selectedIndex.value = 0;
          Get.offAllNamed(AppRoutes.home);
          return false;
        }
        lg.log(
          'LeadsScreen: On home or splash, allowing app exit',
          time: DateTime.now(),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Leads',
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.09,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF36CAA8), Color(0xFF52338A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    tileMode: TileMode.clamp,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Where Every Lead Counts.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (
                                BuildContext context,
                                StateSetter setState,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: SvgPicture.asset(
                                          AppImages.dragIcon,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Filters by',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _dateController,
                                        decoration: InputDecoration(
                                          labelText: 'Select Date',
                                          suffixIcon: IconButton(
                                            icon: SvgPicture.asset(
                                              AppImages.calendarIcon,
                                            ),
                                            onPressed:
                                                () => _selectDate(
                                                  context,
                                                  setState,
                                                ),
                                          ),
                                          labelStyle: const TextStyle(
                                            color: AppColors.grey,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color:
                                                  AppColors
                                                      .textfieldBorderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: AppColors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        readOnly: true,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 50,
                                              child: OutlinedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _dateController.clear();
                                                    lg.log(
                                                      'LeadsScreen: Filter date cleared',
                                                      time: DateTime.now(),
                                                    );
                                                  });
                                                  controller.fetchleadsList(
                                                    context: context,
                                                    reset: true,
                                                    date: null,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                style: OutlinedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  side: const BorderSide(
                                                    color: AppColors.primary,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: const Text(
                                                  'Clear Filter',
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: SizedBox(
                                              height: 50,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  String? formattedDate;
                                                  if (_dateController
                                                      .text
                                                      .isNotEmpty) {
                                                    try {
                                                      final parts =
                                                          _dateController.text
                                                              .split('/');
                                                      if (parts.length == 3) {
                                                        final day = int.parse(
                                                          parts[0],
                                                        );
                                                        final month = int.parse(
                                                          parts[1],
                                                        );
                                                        final year = int.parse(
                                                          parts[2],
                                                        );
                                                        formattedDate =
                                                            '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                                                      } else {
                                                        lg.log(
                                                          'LeadsScreen: Invalid date format: ${_dateController.text}',
                                                          time: DateTime.now(),
                                                        );
                                                        formattedDate = null;
                                                      }
                                                    } catch (e) {
                                                      lg.log(
                                                        'LeadsScreen: Error parsing date: $e',
                                                        time: DateTime.now(),
                                                      );
                                                      formattedDate = null;
                                                    }
                                                  } else {
                                                    lg.log(
                                                      'LeadsScreen: No date selected',
                                                      time: DateTime.now(),
                                                    );
                                                    formattedDate = null;
                                                  }
                                                  lg.log(
                                                    'LeadsScreen: Selected date: ${_dateController.text}, Formatted date: $formattedDate',
                                                    time: DateTime.now(),
                                                  );
                                                  controller.fetchleadsList(
                                                    context: context,
                                                    reset: true,
                                                    date: formattedDate,
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.primary,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                ),
                                                child: const Text('Apply'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      icon: SvgPicture.asset(AppImages.filterIcon),
                    ),
                  ],
                ),
              ),
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                          ),
                          color: const Color(0xFFF5F5F5),
                          elevation: 1,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.recivedLeads.value.toString() ??
                                      "0",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryTeal,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  "Received Leads",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                          ),
                          color: const Color(0xFFF5F5F5),
                          elevation: 1,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.totalLeads.value ?? "0",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  "Total Leads",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshleadsList(context: context),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return CustomShimmer(
                      screenWidth: screenWidth,
                      screenHeight: MediaQuery.of(context).size.height,
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                      print("legnth: ${controller.leadsList.length}");
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
                      return SizedBox(
                        // height: 180, // Constrain the height of each list item
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.leadsDetails,
                              arguments: lead,
                            );
                          },
                          child: LayoutBuilder(
                            builder: (
                              BuildContext context,
                              BoxConstraints constraints,
                            ) {
                              final double screenWidth = constraints.maxWidth;
                              // Use fixed or proportional heights instead of maxHeight
                              final double cardHorizontalMargin =
                                  screenWidth * 0.04;
                              final double cardVerticalMargin = 8.0;
                              final double cardPadding = screenWidth * 0.04;
                              final double fontSize = screenWidth * 0.035;
                              final double buttonWidth = screenWidth * 0.2;
                              final double buttonSpacing = screenWidth * 0.02;
                              final double notePadding = screenWidth * 0.025;
                              final double borderRadius = screenWidth * 0.015;

                              return Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: cardHorizontalMargin,
                                  vertical: cardVerticalMargin,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(cardPadding),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildDetailRow(
                                        "Name",
                                        "${lead.name}",
                                        fontSize,
                                      ),
                                      _buildDetailRow(
                                        "Contact No.",
                                        "${lead.mobileNo}",
                                        fontSize,
                                      ),
                                      _buildDetailRow(
                                        "Date",
                                        "${lead.distributionDate}",
                                        fontSize,
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _cardBottomButtons(
                                            buttonWidth,
                                            color: 0xFF7294EA,
                                            icon: AppImages.callIcon,
                                            title: "Call",
                                            fontSize: fontSize * 0.9,
                                            press: () {
                                              _makingPhoneCall(lead.mobileNo!);
                                            },
                                          ),
                                          SizedBox(width: buttonSpacing),
                                          _cardBottomButtons(
                                            buttonWidth,
                                            color: 0xFF36CAA8,
                                            icon: AppImages.whatsapplIcon,
                                            title: "Whatsapp",
                                            fontSize: fontSize * 0.9,
                                            press: () {
                                              _launchWhatsApp(
                                                context,
                                                lead.whatsappNo!,
                                                "",
                                              );
                                            },
                                          ),
                                          SizedBox(width: buttonSpacing),
                                          _cardBottomButtons(
                                            buttonWidth,
                                            color: 0xFFCA9636,
                                            icon: AppImages.noteIcon,
                                            title: "Note",
                                            fontSize: fontSize * 0.9,
                                            press: () {
                                              _noteDialog(
                                                context,
                                                controller,
                                                lead.noteId.toString(),
                                              );
                                              setState(() {
                                                _noteController.text =
                                                    lead.note!;
                                              });
                                            },
                                          ),
                                          SizedBox(width: buttonSpacing),
                                          _cardBottomButtons(
                                            buttonWidth,
                                            color: 0xFFCA4236,
                                            icon: AppImages.reminderIcon,
                                            title: "Reminder",
                                            fontSize: fontSize * 0.9,
                                            press: () {
                                              _reminderDialog(
                                                context,
                                                controller,
                                                lead.noteId.toString(),
                                                lead.name.toString(),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16.0),
                                      if (lead.note != "" && lead.note != null)
                                        Container(
                                          padding: EdgeInsets.all(notePadding),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              borderRadius,
                                            ),
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                          ),
                                          constraints: const BoxConstraints(
                                            maxHeight: 60.0,
                                          ),
                                          child: Text(
                                            'Note: ${lead.note}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.defaultblack,
                                              fontSize: fontSize * 0.9,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const CustomBottomBar(),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double fontSize) {
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
                color: const Color(0xFF39373C),
                fontSize: fontSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ': $value',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF39373C),
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _noteDialog(BuildContext context, GetLeadsController controller, String id) {
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
                                lg.log(
                                  'LeadsScreen: Note updated for ID: $id, Note: ${_noteController.text.trim()}',
                                  time: DateTime.now(),
                                );
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
    GetLeadsController controller,
    String id,
    String leadName,
  ) {
    String? selectedReminderOption;
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
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Reminder Before',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedReminderOption,
                          items:
                              [
                                    '15 mins',
                                    '30 mins',
                                    '45 mins',
                                    '60 mins',
                                    "Don't remind",
                                  ]
                                  .map(
                                    (option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedReminderOption = value;
                              lg.log(
                                'LeadsScreen: Selected reminder option: $value',
                                time: DateTime.now(),
                              );
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                DateTime followUpDateTime = DateTime(
                                  _selectedReminderDate.year,
                                  _selectedReminderDate.month,
                                  _selectedReminderDate.day,
                                  _selectedTime.hour,
                                  _selectedTime.minute,
                                );

                                final now = DateTime.now();
                                if (followUpDateTime.isBefore(
                                  now.add(const Duration(seconds: 10)),
                                )) {
                                  lg.log(
                                    'LeadsScreen: Invalid follow-up time: $followUpDateTime is too close to now ($now)',
                                    time: DateTime.now(),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a date and time at least 10 seconds in the future.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                String formatDate(DateTime date) {
                                  DateFormat formatter = DateFormat(
                                    'yyyy-MM-dd',
                                  );
                                  return formatter.format(date);
                                }

                                final formatter = DateFormat('HH:mm');
                                String formattedTime = formatter.format(
                                  DateTime(
                                    _selectedReminderDate.year,
                                    _selectedReminderDate.month,
                                    _selectedReminderDate.day,
                                    _selectedTime.hour,
                                    _selectedTime.minute,
                                  ),
                                );

                                String formattedDate = formatDate(
                                  _selectedReminderDate,
                                );

                                controller.setReminder(
                                  id: id,
                                  rdate: formattedDate,
                                  rtime: formattedTime,
                                );

                                final reminderData = {
                                  'lead_id': id,
                                  'lead_name': leadName,
                                  'reminder_date': formattedDate,
                                  'reminder_time': formattedTime,
                                };

                                final existingReminder = await DatabaseHelper
                                    .instance
                                    .getReminderByLeadId(id);
                                if (existingReminder != null) {
                                  await DatabaseHelper.instance.updateReminder(
                                    id,
                                    reminderData,
                                  );
                                  lg.log(
                                    'LeadsScreen: Reminder updated in DB: $id, $formattedDate, $formattedTime',
                                    time: DateTime.now(),
                                  );
                                } else {
                                  await DatabaseHelper.instance.insertReminder(
                                    reminderData,
                                  );
                                  lg.log(
                                    'LeadsScreen: Reminder stored in DB: $id, $formattedDate, $formattedTime',
                                    time: DateTime.now(),
                                  );
                                }

                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                  'global_reminder_option',
                                  selectedReminderOption ?? '30 mins',
                                );
                                lg.log(
                                  'LeadsScreen: Global reminder option saved: $selectedReminderOption',
                                  time: DateTime.now(),
                                );

                                await ReminderNotification()
                                    .scheduleRemindersForAllBookings(
                                      selectedReminderOption,
                                    );

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
    required int color,
    required String icon,
    required String title,
    required VoidCallback press,
    required double fontSize,
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
                style: TextStyle(
                  color: const Color(0xFF39373C),
                  fontSize: fontSize,
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
                      const SizedBox(height: 8),
                      Container(width: 150, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 100, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 16),
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
