// bottom_navigation_controller.dart
import 'package:get/get.dart';
import '../../utility/app_routes.dart';

class BottomNavigationController extends GetxController {
  // -----------------------------------------------------------------
  // 1. Reactive selected index
  // -----------------------------------------------------------------
  final RxInt selectedIndex = 0.obs;

  // -----------------------------------------------------------------
  // 2. Fixed list of routes (the 5 tabs you want)
  // -----------------------------------------------------------------
  final List<String> routes = [
    AppRoutes.home,
    AppRoutes.subscription,
    AppRoutes.leads,
    AppRoutes.videolist,
    AppRoutes.profile,
  ];

  // -----------------------------------------------------------------
  // 3. onInit – sync initial route + listen for changes
  // -----------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    print('BottomNavigationController: Initial route: ${Get.currentRoute}');
    syncIndexWithRoute(Get.currentRoute);

    // Listen to every route change
    ever(Rx<String?>(Get.routing.current), (route) {
      if (route != null) {
        print('BottomNavigationController: Route changed to: $route');
        syncIndexWithRoute(route);
      }
    });
  }

  // -----------------------------------------------------------------
  // 4. Sync the selected index with the current route
  // -----------------------------------------------------------------
  void syncIndexWithRoute(String? route) {
    print(
      'BottomNavigationController: Syncing route: $route, current index: ${selectedIndex.value}',
    );

    if (route == null) {
      print(
        'BottomNavigationController: Route is null, keeping current index: ${selectedIndex.value}',
      );
      return;
    }

    final int index = routes.indexOf(route);
    if (index != -1) {
      selectedIndex.value = index;
      print(
        'BottomNavigationController: Updated selectedIndex to: ${selectedIndex.value}',
      );
    } else {
      print(
        'BottomNavigationController: Route $route not found in routes list',
      );
    }
  }

  // -----------------------------------------------------------------
  // 5. Change tab – preserve navigation stack
  // -----------------------------------------------------------------
  void changeTab(int index) {
    if (index < 0 || index >= routes.length) {
      print('BottomNavigationController: Invalid index: $index');
      return;
    }

    print(
      'BottomNavigationController: Changing tab to index: $index, route: ${routes[index]}',
    );

    // Only navigate if the tab is different
    if (selectedIndex.value != index) {
      selectedIndex.value = index;
      Get.toNamed(routes[index]); // keeps the stack inside the tab
    }
  }

  // -----------------------------------------------------------------
  // 6. Direct “Home” shortcut – reset stack to Home
  // -----------------------------------------------------------------
  void goToHome() {
    print(
      'BottomNavigationController: Navigating to home, setting selectedIndex to 0',
    );
    selectedIndex.value = 0;
    Get.offAllNamed(AppRoutes.home); // clear stack, go to Home
  }

  // -----------------------------------------------------------------
  // 7. Back-button handling (optional but recommended)
  // -----------------------------------------------------------------
  Future<bool> onWillPop() async {
    // 1. Pop inside the current tab’s nested navigator (if any)
    final nested = Get.nestedKey(1)?.currentState;
    if (nested?.canPop() ?? false) {
      Get.back(id: 1);
      return false;
    }

    // 2. If not on Home → go to Home
    if (selectedIndex.value != 0) {
      goToHome();
      return false;
    }

    // 3. On Home + empty stack → allow exit
    return true;
  }
}