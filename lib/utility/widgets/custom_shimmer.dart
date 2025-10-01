import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class cutsomShimmer extends StatelessWidget {
  const cutsomShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                              Container(
                                width: 80,
                                height: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 120,
                            height: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 80,
                                height: 12,
                                color: Colors.white,
                              ),
                              Container(
                                width: 80,
                                height: 12,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
