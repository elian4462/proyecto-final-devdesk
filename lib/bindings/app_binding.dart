import 'package:get/get.dart';
import '../controllers/activos_controller.dart';
import '../controllers/assistant_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/tickets_controller.dart';
import '../services/api_client.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ActivosController>(ActivosController(), permanent: true);
    Get.put<TicketsController>(TicketsController(), permanent: true);
    Get.put<AssistantController>(AssistantController(), permanent: true);
  }
}
