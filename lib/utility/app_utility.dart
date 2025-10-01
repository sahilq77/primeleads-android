import 'package:shared_preferences/shared_preferences.dart';

//created by sahil
class AppUtility {
  static String? userID;
  static String? fullName;
  static String? mobileNumber;
  static String? sectorName;
  static String? sectorID;
  static String? subscriptionID;
  static String? profileImage;
  static bool isLoggedIn = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      // fullName = prefs.getString('full_name');
      // mobileNumber = prefs.getString('mobile_number');
      sectorName = prefs.getString('sector_name');
      sectorID = prefs.getString('sector_id');
      subscriptionID = prefs.getString('subscription_id');
      // profileImage = prefs.getString('profile_image');
      userID = prefs.getString('login_user_id');
    }
  }

  static Future<void> setUserInfo(
    // String name, String mobile,
    String type, // 0= student ,1= open
    //   String profile,
    String userid,
    String sectorid,
    String subId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    // await prefs.setString('full_name', name);
    // await prefs.setString('mobile_number', mobile);
    await prefs.setString('sector_name', type);
    await prefs.setString('subscription_id', subId);
    await prefs.setString('sector_id', sectorid);
    // await prefs.setString('profile_image', profile);
    await prefs.setString('login_user_id', userid);
    // fullName = name;
    // mobileNumber = mobile;
    sectorName = type;
    sectorID = sectorid;
    subscriptionID = subId;
    // profileImage = profile;
    userID = userid;
    // AppUtility.u = userId;
    isLoggedIn = true;
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // fullName = null;
    // mobileNumber = null;
    // userType = null;
    // profileImage = null;

    userID = null;
    isLoggedIn = false;
  }
}
