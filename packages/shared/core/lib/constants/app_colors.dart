import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// region AppColors Class
class AppColors {
  // region Primary Palette
  static const Color primary = Color(0xFFF15A22);
  static const Color primaryVariant = Color(0xFFF7941D);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  static const Color black = Colors.black;
  static const Color black87 = Colors.black87;
  static const Color transparent = Colors.transparent;
  // endregion

  // Assessment Specific Colors
  static const Color assessmentBgDarkBlue = Color(0xFF0A1E50);
  static const Color assessmentAccentCyan = Color(0xFF2B2384);
  static const Color assessmentCardUnderlayer = Color(0xFFFFFFFF);

  // region Neutrals
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // endregion

  // region On Colors (Text/Icons on top of other colors)
  static const Color iconPrimary = Color(0xFF677489);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);

  // endregion

  static const white = Color(0xffffffff);
  static const purple = Color(0xff5C4CEE);
  static const lightWhite = Color(0x33ffffff);
  static const lightWhite2 = Color(0xffd1cccc);
  static const borderColor = Color(0xffE8E8E8);
  static const black300 = Color(0xff626262);
  static const black200 = Color(0xff939393);
  static const black1 = Color(0xff252525);
  static const black2 = Color(0xff8E8E8E);
  static const black3 = Color(0xff262626);
  static const black5 = Color(0xff373737);
  static const black6 = Color(0xff1E1E1E);
  static const black7 = Color(0xff0F0F0F);
  static const black8 = Color(0xff393939);
  static const black4 = Color(0xff252525);
  static const black9 = Color(0xff333333);
  static const black12 = Color(0xffE2E8F0);
  static const black10 = Color(0xff454545);
  static const black11 = Color(0xfff4f8fb);

  static const black13 = Color(0xff1E1E1E);

  //  static const black12 = Color(0xffA9A9A9);
  static const hintText = Color(0xff8C8C8C);
  static const orange = Color(0xffFB8C25);
  static const orange1 = Color(0xffffa600);
  static const textFieldBorderAndHint = Color(0xffA6A6A6);
  static const Color toolsBox = Color(0xFFECEEF8);
  static const welcomeText = Color(0xff252525);
  static const welcomeText1 = Color(0xffD6D8F0);
  static const Color textColor = Color(0xFF000000);
  static const red = Color(0xffF44336);
  static const red1 = Color(0xffFEECEB);
  static const clockIn = Color(0xFF4CAF50);
  static const clockOut = Color(0xFFF44336);
  static const lightGreen = Color(0xff6FD195);
  static const stepperConnector = Color(0xff26A9B8);
  static const green = Color(0xFF0C9510);
  static const lightGreen1 = Color(0xffa3fe00);
  static const lightGreen2 = Color(0xff82E14F);
  static const yellow = Color(0xfffef400);
  static const yellow1 = Color(0xffF2CB70);
  static const boxColor2 = Color(0xFFF5F7F9);
  static const boxColor3 = Color(0xffCCCCCC);
  static const boxColor4 = Color(0xff6C6C6C);
  static const boxColor5 = Color(0xffF6F6F6);
  static const Color textColor5 = Color(0xFFA7A7A7);
  static const Color textColor2 = Color(0xFF5B5B5B);
  static const Color boxColor14 = Color(0xFFF5F5F5);
  static const Color boxColor15 = Color(0xFF5B5B5B);
  static const Color blue = Color(0xFF071987);
  static const Color oliveGreen = Color(0xFFA7CE77);
  static const Color orange2 = Color(0xFFF88178);
  static const Color inProgressColor = Color(0xFFE9E9E9);
  static const Color pendingColor = Color(0xFFD9D9D9);
  static const Color blue1 = Color(0xFF669EFD);

  static Decoration appCardDecoration({
    Color? borderColor = grey50,
    Color? containerColor = white900,
    double borderWidth = 8,
    double borderRadius = 5,
    bool isShadow = true,
  }) {
    return BoxDecoration(
      color: containerColor,
      border: Border.all(color: borderColor ?? grey50, width: 1.0),
      borderRadius: BorderRadius.circular(borderRadius.r),
      boxShadow: isShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                offset: Offset(0, 0),
                blurRadius: 4.9,
                spreadRadius: 0,
              ),
            ]
          : [],
    );
  }

  static const Color lightBlue = Colors.blue;
  static const Color mediumblue = Color(0xFF2572ED);
  static const MaterialColor brightPrimary =
      MaterialColor(_brightPrimaryValue, <int, Color>{
    50: Color(0xFFE8EAF6),
    100: Color(0xFFC5CBE9),
    200: Color(0xFF9FA8DA),
    300: Color(0xFF7985CB),
    400: Color(0xFF5C6BC0),
    500: Color(_brightPrimaryValue),
    600: Color(0xFF394AAE),
    700: Color(0xFF3140A5),
    800: Color(0xFF29379D),
    900: Color(0xFF1B278D),
  });

  static const int _brightPrimaryValue = 0xFF3F51B5;

  //Dashboard leaner gradient
  static const LinearGradient dashboardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5F70CF), Color(0xFF3D4CA1)],
  );

  //region Blue Colors
  static const Color blue50 = Color(0xFFecf3ff);
  static const Color blue100 = Color(0xFFc4d9fe);
  static const Color blue200 = Color(0xFFa7c7fe);
  static const Color blue300 = Color(0xFF7faefe);
  static const Color blue400 = Color(0xFF669efd);
  static const Color blue500 = Color(0xFF4086fd);
  static const Color blue600 = Color(0xFF3a7ae6);
  static const Color blue700 = Color(0xFF2d5fb4);
  static const Color blue800 = Color(0xFF234a8b);
  static const Color blue900 = Color(0xFF1b386a);

  //endregion

  //region Grey Colors
  static const Color grey50 = Color(0xFFE8E8E8);
  static const Color grey100 = Color(0xFFB6B6B6);
  static const Color grey200 = Color(0xFF939393);
  static const Color grey300 = Color(0xFF626262);
  static const Color grey400 = Color(0xFF444444);
  static const Color grey500 = Color(0xFF151515);
  static const Color grey600 = Color(0xFF131313);
  static const Color grey700 = Color(0xFF0F0F0F);
  static const Color grey800 = Color(0xFF0C0C0C);
  static const Color grey900 = Color(0xFF090909);

  //endregion

  //region White Colors
  static const Color white50 = Color(0xFFFFFFFF);
  static const Color white100 = Color(0xFFFFFFFF);
  static const Color white200 = Color(0xFFFFFFFF);
  static const Color white300 = Color(0xFFFFFFFF);
  static const Color white400 = Color(0xFFFFFFFF);
  static const Color white500 = Color(0xFFFFFFFF);
  static const Color white600 = Color(0xFFFFFFFF);
  static const Color white700 = Color(0xFFFFFFFF);
  static const Color white800 = Color(0xFFFFFFFF);
  static const Color white900 = Color(0xFFFFFFFF);

  //endregion

  //region Orange Colors
  static const Color orange50 = Color(0xFFFEECEB);
  static const Color orange100 = Color(0xFFFCC5C1);
  static const Color orange200 = Color(0xFFFAA9A3);
  static const Color orange300 = Color(0xFFF88178);
  static const Color orange400 = Color(0xFFF6695E);
  static const Color orange500 = Color(0xFFF44336);
  static const Color orange600 = Color(0xFFDE3D31);
  static const Color orange700 = Color(0xFFAD3026);
  static const Color orange800 = Color(0xFF86251E);
  static const Color orange900 = Color(0xFF661C17);

  //endregion

  //region Green Colors
  // static const Color green50 = Color(0xFFF3FCED);
  // static const Color green100 = Color(0xFFD8F6C8);
  // static const Color green200 = Color(0xFFC6F1AE);
  // static const Color green300 = Color(0xFFABEB89);
  // static const Color green400 = Color(0xFF9BE772);
  // static const Color green500 = Color(0xFF82E14F);
  // static const Color green600 = Color(0xFF76CD48);
  // static const Color green700 = Color(0xFF5CA038);
  // static const Color green800 = Color(0xFF487C2B);
  // static const Color green900 = Color(0xFF375F21);
  //endregion

  //region Yellow Colors
  static const Color yellow50 = Color(0xFFFDF7EA);
  static const Color yellow100 = Color(0xFFF9E7BD);
  static const Color yellow200 = Color(0xFFF6DB9D);
  static const Color yellow300 = Color(0xFFF2CB70);
  static const Color yellow400 = Color(0xFFEFC155);
  static const Color yellow500 = Color(0xFFEBB12A);
  static const Color yellow600 = Color(0xFFD6A126);
  static const Color yellow700 = Color(0xFFA77E1E);
  static const Color yellow800 = Color(0xFF816117);
  static const Color yellow900 = Color(0xFF634A12);

  //endregion
  static const Color toggleColorTab = Color(0xFFF6F6F6);

  //region Yellow Colors
  static const Color green500 = Color(0xFF82E14F);

  //endregion

  //region Updated Color Definitions
  static const Color greyMedium = Color(0xFF626262);
  static const Color pineOrange = Color(0xFFFF5722);
  static const Color pineBlue = Color(0xFF1A9FD9);
//endregion
}

// endregion










