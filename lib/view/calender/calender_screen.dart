import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:prime_leads/utility/app_routes.dart';
import 'package:prime_leads/utility/app_utility.dart';

import '../../controller/reminder_list/calender_controller.dart';

class CalendarScreen extends StatelessWidget {
  final CalendarController controller = Get.put(CalendarController());

  List<String> _getDaysOfWeek() {
    return ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
  }

  List<Widget> _getCalendarDays() {
    final firstDayOfMonth = DateTime(
      controller.currentDate.value.year,
      controller.currentDate.value.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      controller.currentDate.value.year,
      controller.currentDate.value.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> days = [];
    for (int i = 0; i < firstWeekday; i++) {
      days.add(SizedBox(width: 40, height: 40));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        controller.currentDate.value.year,
        controller.currentDate.value.month,
        day,
      );
      final reminderCount = controller.reminders[date] ?? 0;
      String formatDate(String inputDate) {
        DateTime dateTime = DateTime.parse(inputDate);
        DateFormat formatter = DateFormat('yyyy-MM-dd');
        return formatter.format(dateTime);
      }

      days.add(
        GestureDetector(
          onTap:
              reminderCount > 0
                  ? () {
                    print("object${formatDate(date.toString())}");
                    Get.toNamed(
                      AppRoutes.reminderList,
                      arguments: formatDate(date.toString()),
                    );
                  }
                  : null,
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFDADADA)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (reminderCount > 0)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '$reminderCount Leads',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return days;
  }

  Future<void> _onRefresh() async {
    await controller.refreshCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: false,
        title: Text("Calender", style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(
            color: const Color(0xFFDADADA),
            thickness: 2,
            height: 0,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Obx(
          () =>
              controller.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, size: 35),
                            onPressed: controller.previousMonth,
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(
                              DateTime(
                                controller.currentDate.value.year,
                                controller.currentDate.value.month,
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, size: 35),
                            onPressed: controller.nextMonth,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(
                        color: const Color(0xFFDADADA),
                        thickness: 2,
                        height: 0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            _getDaysOfWeek()
                                .map(
                                  (day) => Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Text(
                                      day,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      Divider(
                        color: const Color(0xFFDADADA),
                        thickness: 2,
                        height: 0,
                      ),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 7,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                          padding: EdgeInsets.all(8),
                          children: _getCalendarDays(),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
