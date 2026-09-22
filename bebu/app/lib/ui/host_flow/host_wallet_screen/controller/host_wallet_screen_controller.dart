import 'package:get/get.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/enums.dart';

class HostWalletScreenController extends GetxController {
  List<Map<String, dynamic>> item = [
    {
      "image": AppAsset.securePayments,
      "name": EnumLocale.txtSecurePayment.name.tr,
    },
    {
      "image": AppAsset.guarantedChat,
      "name": EnumLocale.txtGuarantedChat.name.tr,
    },
    {
      "image": AppAsset.payments,
      "name": EnumLocale.txt1CrPayments.name.tr,
    },
    {
      "image": AppAsset.users,
      "name": EnumLocale.txtTrustedUser.name.tr,
    },
  ];
}
