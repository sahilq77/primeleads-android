import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utility/app_images.dart';
import 'app_colors.dart';

class NoDataScreen extends StatelessWidget {
  const NoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.nodata,
            height: 250,
          ),
          const SizedBox(height: 20),
          Text(
            'Oops!',
            style: GoogleFonts.mukta(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'No data found',
            style: GoogleFonts.mukta(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
