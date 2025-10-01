import 'package:flutter/material.dart';

class VideoListShimmer extends StatelessWidget {
  const VideoListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5, // Show 5 shimmer items
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: [
                Container(
                  width: 150,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: screenWidth * 0.5,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: screenWidth * 0.7,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: screenWidth * 0.4,
                        height: 12,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
