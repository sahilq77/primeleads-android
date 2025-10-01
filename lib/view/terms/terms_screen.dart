import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/nodatascreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:prime_leads/utility/app_colors.dart';

import '../../controller/terms/terms_controller.dart';
import '../../utility/widgets/html_text_design.dart';

class TermsOfUseScreen extends StatefulWidget {
  @override
  _TermsOfUseScreenState createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  bool _isChecked = false;
  final controller = Get.put(TermsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Terms of Use',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        onRefresh: () => controller.refreshleadsList(context: context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () =>
                controller.isLoading.value
                    ? _buildShimmerEffect()
                    : controller.termsList.isEmpty
                    ? NoDataScreen()
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Html(
                          data: (controller.termsList.first.pageContent
                              .replaceAll(r'\r\n', '<br>')),
                          style: TextDesign.commonStyles,
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer for title or header
          Container(
            width: double.infinity,
            height: 20.0,
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8.0),
          ),
          // Shimmer for content paragraphs
          ...List.generate(
            5,
            (index) => Container(
              width: double.infinity,
              height: 16.0,
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 4.0),
            ),
          ),
        ],
      ),
    );
  }
}
