import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_leads/controller/leads/get_lead_detail_controller.dart';
import 'package:prime_leads/model/leads/get_leads_response.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadsDetailScreen extends StatefulWidget {
  const LeadsDetailScreen({super.key});

  @override
  State<LeadsDetailScreen> createState() => _LeadsDetailScreenState();
}

class _LeadsDetailScreenState extends State<LeadsDetailScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _reminderdateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final controller = Get.put(GetLeadDetailController());
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedReminderDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  LeadsData? lead;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final inwarddata = Get.arguments as LeadsData;
    lead = inwarddata;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fecthLeadDtail(context: context, leadId: lead!.noteId ?? "");
    });

    _dateController.text =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
    _reminderdateController.text =
        "${_selectedReminderDate.day}/${_selectedReminderDate.month}/${_selectedReminderDate.year}";
    print('Initial _dateController.text: ${_dateController.text}');
    print(
      'Initial _reminderdateController.text: ${_reminderdateController.text}',
    );
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
        print('Filter date updated: ${_dateController.text}');
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
        print('Reminder date updated: ${_reminderdateController.text}');
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
        print('Time updated: ${_timeController.text}');
      });
    }
  }

  Future<void> _makingPhoneCall(String num) async {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'WhatsApp is not installed or the phone number is invalid',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  void _clearDate() {
    setState(() {
      _dateController.clear();
      print('Filter date cleared');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Lead Details',
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
      body: Obx(
        () =>
            controller.isLoading.value
                ? _buildShimmerEffect(screenWidth, screenHeight)
                : controller.leadsDetailList.isEmpty
                ? _buildNoDataWidget(screenHeight)
                : RefreshIndicator(
                  onRefresh:
                      () => controller.fecthLeadDtail(
                        context: context,
                        leadId: lead!.noteId ?? "",
                        reset: true,
                      ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              "Name",
                              "${controller.leadsDetailList.first.name}",
                            ),
                            _buildDetailRow(
                              "Contact No.",
                              "${controller.leadsDetailList.first.mobileNo}",
                            ),
                            _buildDetailRow("Category", "${lead!.sectorName}"),
                            _buildDetailRow(
                              "Location",
                              "${controller.leadsDetailList.first.location}",
                            ),
                            _buildDetailRow(
                              "City",
                              "${controller.leadsDetailList.first.city}",
                            ),
                            _buildDetailRow(
                              "State",
                              "${controller.leadsDetailList.first.state}",
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     _cardBottomButtons(
                            //       screenWidth,
                            //       color: 0xFF7294EA,
                            //       icon: AppImages.callIcon,
                            //       title: "Call",
                            //       press:
                            //           () => _makingPhoneCall(lead!.mobileNo!),
                            //     ),
                            //     _cardBottomButtons(
                            //       screenWidth,
                            //       color: 0xFF36CAA8,
                            //       icon: AppImages.whatsapplIcon,
                            //       title: "Whatsapp",
                            //       press:
                            //           () => _launchWhatsApp(
                            //             context,
                            //             lead!.whatsappNo!,
                            //             "",
                            //           ),
                            //     ),
                            //     _cardBottomButtons(
                            //       screenWidth,
                            //       color: 0xFFCA9636,
                            //       icon: AppImages.noteIcon,
                            //       title: "Note",
                            //       press: () {
                            //         _noteController.text = lead!.note ?? "";
                            //         _noteDialog(
                            //           context,
                            //           controller,
                            //           controller.leadsDetailList.first.note ??
                            //               "",
                            //         );
                            //       },
                            //     ),
                            //     _cardBottomButtons(
                            //       screenWidth,
                            //       color: 0xFFCA4236,
                            //       icon: AppImages.reminderIcon,
                            //       title: "Reminder",
                            //       press:
                            //           () => _reminderDialog(
                            //             context,
                            //             controller,
                            //             _selectedReminderDate.toString(),
                            //             _selectedTime.toString(),
                            //             lead!.noteId.toString(),
                            //           ),
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(height: screenHeight * 0.01),
                            Divider(),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Additional Lead Details',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Table(
                              border: TableBorder.all(
                                color: const Color(0xFF9E9E9E),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(1),
                              },
                              children:
                                  controller
                                      .leadsDetailList
                                      .first
                                      .additionalDetails
                                      .map<TableRow>((detail) {
                                        return TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                detail.title
                                                    .replaceAll('_', ' ')
                                                    .replaceAllMapped(
                                                      RegExp(
                                                        r'(^|[^A-Za-z])([A-Z])',
                                                      ),
                                                      (match) =>
                                                          '${match[1]} ${match[2]}',
                                                    )
                                                    .toLowerCase()
                                                    .replaceFirstMapped(
                                                      RegExp(r'^\w'),
                                                      (match) =>
                                                          match[0]!
                                                              .toUpperCase(),
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                detail.value,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                      .toList(),
                            ),
                            if (controller.leadsDetailList.first.note != null &&
                                controller
                                    .leadsDetailList
                                    .first
                                    .note!
                                    .isNotEmpty)
                              Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.01),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                    child: Text(
                                      'Note: ${controller.leadsDetailList.first.note}',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.defaultblack,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildShimmerEffect(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerRow(screenWidth),
                _buildShimmerRow(screenWidth),
                _buildShimmerRow(screenWidth),
                _buildShimmerRow(screenWidth),
                _buildShimmerRow(screenWidth),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (index) => Container(
                      height: 30,
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Divider(),
                SizedBox(height: screenHeight * 0.01),
                Container(width: 150, height: 20, color: Colors.white),
                SizedBox(height: screenHeight * 0.01),
                Table(
                  border: TableBorder.all(color: const Color(0xFF9E9E9E)),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                  },
                  children: List.generate(
                    3,
                    (index) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(height: 13, color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(height: 13, color: Colors.white),
                        ),
                      ],
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

  Widget _buildShimmerRow(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 90, height: 13, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget(double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: screenHeight * 0.2),
          const Icon(Icons.info_outline, size: 60, color: AppColors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Lead Details Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please try refreshing or check the lead ID',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
                color: const Color(0xFF39373C),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _noteDialog(
    BuildContext context,
    GetLeadDetailController controller,
    String id,
  ) {
    showDialog(
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
                                Navigator.pop(context);
                                _noteController.clear();
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
                            onPressed: () => Navigator.pop(context),
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

  void _reminderDialog(
    BuildContext context,
    GetLeadDetailController controller,
    String date,
    String time,
    String id,
  ) {
    showDialog(
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
                            onPressed: () => Navigator.pop(context),
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

  Widget _cardBottomButtons(
    double screenWidth, {
    required int color,
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
