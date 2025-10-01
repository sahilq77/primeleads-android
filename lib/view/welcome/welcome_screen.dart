import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/app_routes.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _current = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final List<Map<String, String>> _slides = [
    {
      'title': 'Welcome To!',
      'subtitle': 'Prime Leads',
      'description':
          'Precision Leads. Prime Results. Get high-quality leads delivered to you daily.',
      'image': AppImages.welcome1,
    },
    {
      'title': 'Choose Your City \n& Get Daily Leads',
      'subtitle': '',
      'description':
          'Easily select your target location and receive fresh, verified leads every day-right in the app.',
      'image': AppImages.welcome2,
    },
    {
      'title': 'Turn Leads Into \nClients-Faster',
      'subtitle': '',
      'description':
          'Get access to follow-up tutorials, expert strategies, and a supportive team to grow your business faster.',
      'image': AppImages.welcome3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: _slides.length,
            itemBuilder: (context, index, realIdx) {
              final slide = _slides[index];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * (isTablet ? 0.1 : 0.15)),
                    Container(
                      height: constraints.maxHeight * (isTablet ? 0.35 : 0.3),
                      width: constraints.maxWidth * 0.9,
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(slide['image']!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.05,
                      ),
                      child: Card(
                        color: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
                          child: Column(
                            children: [
                              Text(
                                slide['title']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 32 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (slide['subtitle']!.isNotEmpty)
                                Text(
                                  slide['subtitle']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 36 : 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              SizedBox(height: 10),
                              Text(
                                slide['description']!,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.08),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Get.toNamed(AppRoutes.login);
                                    },
                                    child: Text(
                                      'Skip',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: isTablet ? 18 : 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children:
                                          _slides.asMap().entries.map((entry) {
                                            return Container(
                                              width: isTablet ? 24.0 : 20.0,
                                              height: 8.0,
                                              margin: EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 4.0,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                color:
                                                    _current == entry.key
                                                        ? Colors.teal
                                                        : Colors.white,
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_current < _slides.length - 1) {
                                        _carouselController.nextPage(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      } else {
                                        Get.toNamed(AppRoutes.login);
                                      }
                                    },
                                    child: Text(
                                      _current == _slides.length - 1
                                          ? 'Done'
                                          : 'Next',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: isTablet ? 18 : 16,
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
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: constraints.maxHeight,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() => _current = index);
              },
            ),
          );
        },
      ),
    );
  }
}
