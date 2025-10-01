// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// // import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:prime_leads/utility/app_colors.dart';
// // import 'package:share_plus/share_plus.dart';

// import '../../controller/payment_list/payment_receipt_controller.dart';

// class ViewResultScreen extends StatefulWidget {
//   ViewResultScreen({super.key});

//   @override
//   _ViewResultScreenState createState() => _ViewResultScreenState();
// }

// class _ViewResultScreenState extends State<ViewResultScreen> {
//   final controller = Get.put(PaymentReceiptController());
//   String productID = '';
//   String? receiptUrl; // To store the receipt URL
//   bool isLoading = true; // To manage API loading state

//   @override
//   void initState() {
//     super.initState();

//     // setState(() {
//     //   controller.fetchReciptUrl(id: "1", context: context);
//     // });
//   }

//   void shareReceiptUrl() {
//     if (controller.url != null) {
//       final String customMessage =
//           'Here is your bill receipt:\n${"https://seekhelp.in/prime-lead/payment_recipt/1/1/1"}';

//       // Share.share(customMessage, subject: 'Result');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No Result URL available to share.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("url: ${controller.url.value}");

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         automaticallyImplyLeading: true,
//         title: const Text('Result View'),
//         elevation: 0,
//         bottom: const PreferredSize(
//           preferredSize: Size.fromHeight(1.0),
//           child: Divider(height: 1, color: Color(0xFFE5E7EB)),
//         ),
//       ),
//       backgroundColor: AppColors.background,

//       body: PDF(fitEachPage: true).fromUrl(
//         "https://seekhelp.in/prime-lead/payment_recipt/1/1/1",
//         placeholder:
//             (progress) =>
//                 Center(child: CircularProgressIndicator(value: progress)),
//         errorWidget: (error) => Center(child: Text(error.toString())),
//       ),

//       floatingActionButton: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           // FloatingActionButton(
//           //   onPressed: fetchReportPdf,
//           //   heroTag: 'refresh', // Trigger refresh action
//           //   child: const Icon(Icons.refresh),
//           // ),
//           //  const SizedBox(height: 10),
//           FloatingActionButton(
//             onPressed: shareReceiptUrl,
//             heroTag: 'share', // Trigger share action
//             child: const Icon(Icons.share),
//           ),
//         ],
//       ),
//     );
//   }
// }
