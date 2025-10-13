import 'package:get/get.dart';
import 'package:prime_leads/controller/leads/get_leads_controller.dart';
import 'package:prime_leads/controller/video/video_controller.dart';

class LeadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetLeadsController>(() => GetLeadsController());
  }
}
