import 'package:get/get.dart';
import '../../utility/app_routes.dart';

class BottomNavigationController extends GetxController {
  RxInt selectedIndex = 0.obs;

  final List<String> routes = [
    AppRoutes.home,
    AppRoutes.subscription,
    AppRoutes.leads,
    AppRoutes.videolist,
    AppRoutes.profile,
  ];

  @override
  void onInit() {
    super.onInit();
    print('BottomNavigationController: Initial route: ${Get.currentRoute}');
    syncIndexWithRoute(Get.currentRoute);
    ever(Rx<String?>(Get.routing.current), (route) {
      if (route != null) {
        print('BottomNavigationController: Route changed to: $route');
        syncIndexWithRoute(route);
      }
    });
  }

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
    final index = routes.indexOf(route);
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

  void changeTab(int index) {
    if (index < 0 || index >= routes.length) {
      print('BottomNavigationController: Invalid index: $index');
      return;
    }
    print(
      'BottomNavigationController: Changing tab to index: $index, route: ${routes[index]}',
    );
    selectedIndex.value = index;
    Get.toNamed(routes[index]); // Use toNamed to preserve stack
  }

  void goToHome() {
    print(
      'BottomNavigationController: Navigating to home, setting selectedIndex to 0',
    );
    selectedIndex.value = 0;
    Get.offAllNamed(
      AppRoutes.home,
    ); // Use offAllNamed for explicit home navigation
  }
}
