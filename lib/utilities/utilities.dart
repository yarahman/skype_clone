import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as im;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../enums/user_state.dart';

class Utilities {
  static String getUserName(String userName) {
    return 'live${userName.split('@')[0]}';
  }

  static String initials(String name) {
    List<String> nameSpilt = name.split(' ');
    final firstName = nameSpilt[0][0];
    final lastName = nameSpilt[1][0];
    return firstName + lastName;
  }

  static Future<File> pickImage(ImageSource imageSource) async {
    final ref = ImagePicker();
    final image = await ref.pickImage(source: imageSource);
    final fileImage = File(image!.path);

    return comprossedImage(fileImage);
  }

  static Future<File> comprossedImage(File imageToCompressed) async {
    final tempDir = await getTemporaryDirectory();

    final path = tempDir.path;

    int randomNum = Random().nextInt(100000);

    im.Image? image = im.decodeImage(imageToCompressed.readAsBytesSync());
    im.copyResize(image!, height: 500, width: 500);

    return File('$path/img_$randomNum.jpg')
      ..writeAsBytesSync(im.encodeJpg(image, quality: 85));
  }

  static int stateToNum(UserState userState) {
    switch (userState) {
      case UserState.offLine:
        return 0;

      case UserState.onLIne:
        return 1;

      default:
        return 2;
    }
  }

  static UserState numToState(int num) {
    switch (num) {
      case 0:
        return UserState.offLine;

      case 1:
        return UserState.onLIne;

      default:
        return UserState.waiting;
    }
  }
}
