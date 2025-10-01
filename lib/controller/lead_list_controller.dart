import 'package:get/get.dart';

class LeadListController extends GetxController{
  RxList leads=[
    {
      "name": "Abhay Patil",
       "mobile": "+91 9975947878",
       "date": "20/05/2015",
        "location": "Pune, Maharashtra",
          "note": "After payment document can be downloaded from order section only once which you can share."
    },
     {
      "name": "Anil Patil",
       "mobile": "+91 997594777",
       "date": "20/05/2015",
        "location": "Mmbai, Maharashtra",
          "note": null
    }
  ].obs;
}