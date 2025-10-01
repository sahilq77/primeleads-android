import 'package:get/get.dart';
import 'package:prime_leads/controller/video/video_controller.dart';

class VideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoController>(() => VideoController());
  }
}
