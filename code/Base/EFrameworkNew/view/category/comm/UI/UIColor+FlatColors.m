// The MIT License (MIT)
//
// Copyright (c) 2014 Giovanni Lodi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "UIColor+FlatColors.h"

@implementation UIColor (FlatColors)

// See http://blog.alexedge.co.uk/speeding-up-uicolor-categories/
#if __has_feature(objc_arc)
#define AGEColorImplement(COLOR_NAME,RED,GREEN,BLUE)    \
+ (UIColor *)COLOR_NAME{    \
    static UIColor* COLOR_NAME##_color;    \
    static dispatch_once_t COLOR_NAME##_onceToken;   \
    dispatch_once(&COLOR_NAME##_onceToken, ^{    \
        COLOR_NAME##_color = [UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0];  \
    }); \
    return COLOR_NAME##_color;  \
}
#else
#define AGEColorImplement(COLOR_NAME,RED,GREEN,BLUE)    \
+ (UIColor *)COLOR_NAME{    \
    static UIColor* COLOR_NAME##_color;    \
    static dispatch_once_t COLOR_NAME##_onceToken;   \
    dispatch_once(&COLOR_NAME##_onceToken, ^{    \
        COLOR_NAME##_color = [[UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:1.0]retain];  \
    }); \
    return COLOR_NAME##_color;  \
}

#endif

AGEColorImplement(flatTurquoiseColor, 0.10196078431372549, 0.7372549019607844, 0.611764705882353)
AGEColorImplement(flatGreenSeaColor, 0.08627450980392157, 0.6274509803921569, 0.5215686274509804)
AGEColorImplement(flatEmeraldColor, 0.1803921568627451, 0.8, 0.44313725490196076)
AGEColorImplement(flatNephritisColor, 0.15294117647058825, 0.6823529411764706, 0.3764705882352941)
AGEColorImplement(flatPeterRiverColor, 0.20392156862745098, 0.596078431372549, 0.8588235294117647)
AGEColorImplement(flatBelizeHoleColor, 0.1607843137254902, 0.5019607843137255, 0.7254901960784313)
AGEColorImplement(flatAmethystColor, 0.6078431372549019, 0.34901960784313724, 0.7137254901960784)
AGEColorImplement(flatWisteriaColor, 0.5568627450980392, 0.26666666666666666, 0.6784313725490196)
AGEColorImplement(flatWetAsphaltColor, 0.20392156862745098, 0.28627450980392155, 0.3686274509803922)
AGEColorImplement(flatMidnightBlueColor, 0.17254901960784313, 0.24313725490196078, 0.3137254901960784)
AGEColorImplement(flatSunFlowerColor, 0.9450980392156862, 0.7686274509803922, 0.058823529411764705)
AGEColorImplement(flatOrangeColor, 0.9529411764705882, 0.611764705882353, 0.07058823529411765)
AGEColorImplement(flatCarrotColor, 0.9019607843137255, 0.49411764705882355, 0.13333333333333333)
AGEColorImplement(flatPumpkinColor, 0.8274509803921568, 0.32941176470588235, 0)
AGEColorImplement(flatAlizarinColor, 0.9058823529411765, 0.2980392156862745, 0.23529411764705882)
AGEColorImplement(flatPomegranateColor, 0.7529411764705882, 0.2235294117647059, 0.16862745098039217)
AGEColorImplement(flatCloudsColor, 0.9254901960784314, 0.9411764705882353, 0.9450980392156862)
AGEColorImplement(flatSilverColor, 0.7411764705882353, 0.7647058823529411, 0.7803921568627451)
AGEColorImplement(flatConcreteColor, 0.5843137254901961, 0.6470588235294118, 0.6509803921568628)
AGEColorImplement(flatAsbestosColor, 0.4980392156862745, 0.5490196078431373, 0.5529411764705883)


+ (UIColor *)md_red_50{
    return [UIColor fromHexValue:0xffebee];
}

+ (UIColor *)md_red_100{
    return [UIColor fromHexValue:0xffcdd2];
}

+ (UIColor *)md_red_200{
    return [UIColor fromHexValue:0xef9a9a];
}

+ (UIColor *)md_red_300{
    return [UIColor fromHexValue:0xe57373];
}

+ (UIColor *)md_red_400{
    return [UIColor fromHexValue:0xef5350];
}

+ (UIColor *)md_red_500{
    return [UIColor fromHexValue:0xf44336];
}

+ (UIColor *)md_red_600{
    return [UIColor fromHexValue:0xe53935];
}

+ (UIColor *)md_red_700{
    return [UIColor fromHexValue:0xd32f2f];
}

+ (UIColor *)md_red_800{
    return [UIColor fromHexValue:0xc62828];
}

+ (UIColor *)md_red_900{
    return [UIColor fromHexValue:0xb71c1c];
}

+ (UIColor *)md_red_A100{
    return [UIColor fromHexValue:0xff8a80];
}

+ (UIColor *)md_red_A200{
    return [UIColor fromHexValue:0xff5252];
}

+ (UIColor *)md_red_A400{
    return [UIColor fromHexValue:0xff1744];
}

+ (UIColor *)md_red_A700{
    return [UIColor fromHexValue:0xd50000];
}

+ (UIColor *)md_pink_50{
    return [UIColor fromHexValue:0xfce4ec];
}

+ (UIColor *)md_pink_100{
    return [UIColor fromHexValue:0xf8bbd0];
}

+ (UIColor *)md_pink_200{
    return [UIColor fromHexValue:0xf48fb1];
}

+ (UIColor *)md_pink_300{
    return [UIColor fromHexValue:0xf06292];
}

+ (UIColor *)md_pink_400{
    return [UIColor fromHexValue:0xec407a];
}

+ (UIColor *)md_pink_500{
    return [UIColor fromHexValue:0xe91e63];
}

+ (UIColor *)md_pink_600{
    return [UIColor fromHexValue:0xd81b60];
}

+ (UIColor *)md_pink_700{
    return [UIColor fromHexValue:0xc2185b];
}

+ (UIColor *)md_pink_800{
    return [UIColor fromHexValue:0xad1457];
}

+ (UIColor *)md_pink_900{
    return [UIColor fromHexValue:0x880e4f];
}

+ (UIColor *)md_pink_A100{
    return [UIColor fromHexValue:0xff80ab];
}

+ (UIColor *)md_pink_A200{
    return [UIColor fromHexValue:0xff4081];
}

+ (UIColor *)md_pink_A400{
    return [UIColor fromHexValue:0xf50057];
}

+ (UIColor *)md_pink_A700{
    return [UIColor fromHexValue:0xc51162];
}

+ (UIColor *)md_purple_50{
    return [UIColor fromHexValue:0xf3e5f5];
}

+ (UIColor *)md_purple_100{
    return [UIColor fromHexValue:0xe1bee7];
}

+ (UIColor *)md_purple_200{
    return [UIColor fromHexValue:0xce93d8];
}

+ (UIColor *)md_purple_300{
    return [UIColor fromHexValue:0xba68c8];
}

+ (UIColor *)md_purple_400{
    return [UIColor fromHexValue:0xab47bc];
}

+ (UIColor *)md_purple_500{
    return [UIColor fromHexValue:0x9c27b0];
}

+ (UIColor *)md_purple_600{
    return [UIColor fromHexValue:0x8e24aa];
}

+ (UIColor *)md_purple_700{
    return [UIColor fromHexValue:0x7b1fa2];
}

+ (UIColor *)md_purple_800{
    return [UIColor fromHexValue:0x6a1b9a];
}

+ (UIColor *)md_purple_900{
    return [UIColor fromHexValue:0x4a148c];
}

+ (UIColor *)md_purple_A100{
    return [UIColor fromHexValue:0xea80fc];
}

+ (UIColor *)md_purple_A200{
    return [UIColor fromHexValue:0xe040fb];
}

+ (UIColor *)md_purple_A400{
    return [UIColor fromHexValue:0xd500f9];
}

+ (UIColor *)md_purple_A700{
    return [UIColor fromHexValue:0xaa00ff];
}

+ (UIColor *)md_purple_Good{
    return [UIColor colorWithRed:70/255.f green:95/255.f blue:140/255.f alpha:1.0];
}

+ (UIColor *)md_deep_purple_50{
    return [UIColor fromHexValue:0xede7f6];
}

+ (UIColor *)md_deep_purple_100{
    return [UIColor fromHexValue:0xd1c4e9];
}

+ (UIColor *)md_deep_purple_200{
    return [UIColor fromHexValue:0xb39ddb];
}

+ (UIColor *)md_deep_purple_300{
    return [UIColor fromHexValue:0x9575cd];
}

+ (UIColor *)md_deep_purple_400{
    return [UIColor fromHexValue:0x7e57c2];
}

+ (UIColor *)md_deep_purple_500{
    return [UIColor fromHexValue:0x673ab7];
}

+ (UIColor *)md_deep_purple_600{
    return [UIColor fromHexValue:0x5e35b1];
}

+ (UIColor *)md_deep_purple_700{
    return [UIColor fromHexValue:0x512da8];
}

+ (UIColor *)md_deep_purple_800{
    return [UIColor fromHexValue:0x4527a0];
}

+ (UIColor *)md_deep_purple_900{
    return [UIColor fromHexValue:0x311b92];
}

+ (UIColor *)md_deep_purple_A100{
    return [UIColor fromHexValue:0xb388ff];
}

+ (UIColor *)md_deep_purple_A200{
    return [UIColor fromHexValue:0x7c4dff];
}

+ (UIColor *)md_deep_purple_A400{
    return [UIColor fromHexValue:0x651fff];
}

+ (UIColor *)md_deep_purple_A700{
    return [UIColor fromHexValue:0x6200ea];
}

+ (UIColor *)md_indigo_50{
    return [UIColor fromHexValue:0xe8eaf6];
}

+ (UIColor *)md_indigo_100{
    return [UIColor fromHexValue:0xc5cae9];
}

+ (UIColor *)md_indigo_200{
    return [UIColor fromHexValue:0x9fa8da];
}

+ (UIColor *)md_indigo_300{
    return [UIColor fromHexValue:0x7986cb];
}

+ (UIColor *)md_indigo_400{
    return [UIColor fromHexValue:0x5c6bc0];
}

+ (UIColor *)md_indigo_500{
    return [UIColor fromHexValue:0x3f51b5];
}

+ (UIColor *)md_indigo_600{
    return [UIColor fromHexValue:0x3949ab];
}

+ (UIColor *)md_indigo_700{
    return [UIColor fromHexValue:0x303f9f];
}

+ (UIColor *)md_indigo_800{
    return [UIColor fromHexValue:0x283593];
}

+ (UIColor *)md_indigo_900{
    return [UIColor fromHexValue:0x1a237e];
}

+ (UIColor *)md_indigo_A100{
    return [UIColor fromHexValue:0x8c9eff];
}

+ (UIColor *)md_indigo_A200{
    return [UIColor fromHexValue:0x536dfe];
}

+ (UIColor *)md_indigo_A400{
    return [UIColor fromHexValue:0x3d5afe];
}

+ (UIColor *)md_indigo_A700{
    return [UIColor fromHexValue:0x304ffe];
}

+ (UIColor *)md_blue_50{
    return [UIColor fromHexValue:0xe3f2fd];
}

+ (UIColor *)md_blue_100{
    return [UIColor fromHexValue:0xbbdefb];
}

+ (UIColor *)md_blue_200{
    return [UIColor fromHexValue:0x90caf9];
}

+ (UIColor *)md_blue_300{
    return [UIColor fromHexValue:0x64b5f6];
}

+ (UIColor *)md_blue_400{
    return [UIColor fromHexValue:0x42a5f5];
}

+ (UIColor *)md_blue_500{
    return [UIColor fromHexValue:0x2196f3];
}

+ (UIColor *)md_blue_600{
    return [UIColor fromHexValue:0x1e88e5];
}

+ (UIColor *)md_blue_700{
    return [UIColor fromHexValue:0x1976d2];
}

+ (UIColor *)md_blue_800{
    return [UIColor fromHexValue:0x1565c0];
}

+ (UIColor *)md_blue_900{
    return [UIColor fromHexValue:0x0d47a1];
}

+ (UIColor *)md_blue_A100{
    return [UIColor fromHexValue:0x82b1ff];
}

+ (UIColor *)md_blue_A200{
    return [UIColor fromHexValue:0x448aff];
}

+ (UIColor *)md_blue_A400{
    return [UIColor fromHexValue:0x2979ff];
}

+ (UIColor *)md_blue_A700{
    return [UIColor fromHexValue:0x2962ff];
}

+ (UIColor *)md_light_blue_50{
    return [UIColor fromHexValue:0xe1f5fe];
}

+ (UIColor *)md_light_blue_100{
    return [UIColor fromHexValue:0xb3e5fc];
}

+ (UIColor *)md_light_blue_200{
    return [UIColor fromHexValue:0x81d4fa];
}

+ (UIColor *)md_light_blue_300{
    return [UIColor fromHexValue:0x4fc3f7];
}

+ (UIColor *)md_light_blue_400{
    return [UIColor fromHexValue:0x29b6f6];
}

+ (UIColor *)md_light_blue_500{
    return [UIColor fromHexValue:0x03a9f4];
}

+ (UIColor *)md_light_blue_600{
    return [UIColor fromHexValue:0x039be5];
}

+ (UIColor *)md_light_blue_700{
    return [UIColor fromHexValue:0x0288d1];
}

+ (UIColor *)md_light_blue_800{
    return [UIColor fromHexValue:0x0277bd];
}

+ (UIColor *)md_light_blue_900{
    return [UIColor fromHexValue:0x01579b];
}

+ (UIColor *)md_light_blue_A100{
    return [UIColor fromHexValue:0x80d8ff];
}

+ (UIColor *)md_light_blue_A200{
    return [UIColor fromHexValue:0x40c4ff];
}

+ (UIColor *)md_light_blue_A400{
    return [UIColor fromHexValue:0x00b0ff];
}

+ (UIColor *)md_light_blue_A700{
    return [UIColor fromHexValue:0x0091ea];
}

+ (UIColor *)md_cyan_50{
    return [UIColor fromHexValue:0xe0f7fa];
}

+ (UIColor *)md_cyan_100{
    return [UIColor fromHexValue:0xb2ebf2];
}

+ (UIColor *)md_cyan_200{
    return [UIColor fromHexValue:0x80deea];
}

+ (UIColor *)md_cyan_300{
    return [UIColor fromHexValue:0x4dd0e1];
}

+ (UIColor *)md_cyan_400{
    return [UIColor fromHexValue:0x26c6da];
}

+ (UIColor *)md_cyan_500{
    return [UIColor fromHexValue:0x00bcd4];
}

+ (UIColor *)md_cyan_600{
    return [UIColor fromHexValue:0x00acc1];
}

+ (UIColor *)md_cyan_700{
    return [UIColor fromHexValue:0x0097a7];
}

+ (UIColor *)md_cyan_800{
    return [UIColor fromHexValue:0x00838f];
}

+ (UIColor *)md_cyan_900{
    return [UIColor fromHexValue:0x006064];
}

+ (UIColor *)md_cyan_A100{
    return [UIColor fromHexValue:0x84ffff];
}

+ (UIColor *)md_cyan_A200{
    return [UIColor fromHexValue:0x18ffff];
}

+ (UIColor *)md_cyan_A400{
    return [UIColor fromHexValue:0x00e5ff];
}

+ (UIColor *)md_cyan_A700{
    return [UIColor fromHexValue:0x00b8d4];
}

+ (UIColor *)md_teal_50{
    return [UIColor fromHexValue:0xe0f2f1];
}

+ (UIColor *)md_teal_100{
    return [UIColor fromHexValue:0xb2dfdb];
}

+ (UIColor *)md_teal_200{
    return [UIColor fromHexValue:0x80cbc4];
}

+ (UIColor *)md_teal_300{
    return [UIColor fromHexValue:0x4db6ac];
}

+ (UIColor *)md_teal_400{
    return [UIColor fromHexValue:0x26a69a];
}

+ (UIColor *)md_teal_500{
    return [UIColor fromHexValue:0x009688];
}

+ (UIColor *)md_teal_600{
    return [UIColor fromHexValue:0x00897b];
}

+ (UIColor *)md_teal_700{
    return [UIColor fromHexValue:0x00796b];
}

+ (UIColor *)md_teal_800{
    return [UIColor fromHexValue:0x00695c];
}

+ (UIColor *)md_teal_900{
    return [UIColor fromHexValue:0x004d40];
}

+ (UIColor *)md_teal_A100{
    return [UIColor fromHexValue:0xa7ffeb];
}

+ (UIColor *)md_teal_A200{
    return [UIColor fromHexValue:0x64ffda];
}

+ (UIColor *)md_teal_A400{
    return [UIColor fromHexValue:0x1de9b6];
}

+ (UIColor *)md_teal_A700{
    return [UIColor fromHexValue:0x00bfa5];
}

+ (UIColor *)md_green_50{
    return [UIColor fromHexValue:0xe8f5e9];
}

+ (UIColor *)md_green_100{
    return [UIColor fromHexValue:0xc8e6c9];
}

+ (UIColor *)md_green_200{
    return [UIColor fromHexValue:0xa5d6a7];
}

+ (UIColor *)md_green_300{
    return [UIColor fromHexValue:0x81c784];
}

+ (UIColor *)md_green_400{
    return [UIColor fromHexValue:0x66bb6a];
}

+ (UIColor *)md_green_500{
    return [UIColor fromHexValue:0x4caf50];
}

+ (UIColor *)md_green_600{
    return [UIColor fromHexValue:0x43a047];
}

+ (UIColor *)md_green_700{
    return [UIColor fromHexValue:0x388e3c];
}

+ (UIColor *)md_green_800{
    return [UIColor fromHexValue:0x2e7d32];
}

+ (UIColor *)md_green_900{
    return [UIColor fromHexValue:0x1b5e20];
}

+ (UIColor *)md_green_A100{
    return [UIColor fromHexValue:0xb9f6ca];
}

+ (UIColor *)md_green_A200{
    return [UIColor fromHexValue:0x69f0ae];
}

+ (UIColor *)md_green_A400{
    return [UIColor fromHexValue:0x00e676];
}

+ (UIColor *)md_green_A700{
    return [UIColor fromHexValue:0x00c853];
}

+ (UIColor *)md_light_green_50{
    return [UIColor fromHexValue:0xf1f8e9];
}

+ (UIColor *)md_light_green_100{
    return [UIColor fromHexValue:0xdcedc8];
}

+ (UIColor *)md_light_green_200{
    return [UIColor fromHexValue:0xc5e1a5];
}

+ (UIColor *)md_light_green_300{
    return [UIColor fromHexValue:0xaed581];
}

+ (UIColor *)md_light_green_400{
    return [UIColor fromHexValue:0x9ccc65];
}

+ (UIColor *)md_light_green_500{
    return [UIColor fromHexValue:0x8bc34a];
}

+ (UIColor *)md_light_green_600{
    return [UIColor fromHexValue:0x7cb342];
}

+ (UIColor *)md_light_green_700{
    return [UIColor fromHexValue:0x689f38];
}

+ (UIColor *)md_light_green_800{
    return [UIColor fromHexValue:0x558b2f];
}

+ (UIColor *)md_light_green_900{
    return [UIColor fromHexValue:0x33691e];
}

+ (UIColor *)md_light_green_A100{
    return [UIColor fromHexValue:0xccff90];
}

+ (UIColor *)md_light_green_A200{
    return [UIColor fromHexValue:0xb2ff59];
}

+ (UIColor *)md_light_green_A400{
    return [UIColor fromHexValue:0x76ff03];
}

+ (UIColor *)md_light_green_A700{
    return [UIColor fromHexValue:0x64dd17];
}

+ (UIColor *)md_lime_50{
    return [UIColor fromHexValue:0xf9fbe7];
}

+ (UIColor *)md_lime_100{
    return [UIColor fromHexValue:0xf0f4c3];
}

+ (UIColor *)md_lime_200{
    return [UIColor fromHexValue:0xe6ee9c];
}

+ (UIColor *)md_lime_300{
    return [UIColor fromHexValue:0xdce775];
}

+ (UIColor *)md_lime_400{
    return [UIColor fromHexValue:0xd4e157];
}

+ (UIColor *)md_lime_500{
    return [UIColor fromHexValue:0xcddc39];
}

+ (UIColor *)md_lime_600{
    return [UIColor fromHexValue:0xc0ca33];
}

+ (UIColor *)md_lime_700{
    return [UIColor fromHexValue:0xafb42b];
}

+ (UIColor *)md_lime_800{
    return [UIColor fromHexValue:0x9e9d24];
}

+ (UIColor *)md_lime_900{
    return [UIColor fromHexValue:0x827717];
}

+ (UIColor *)md_lime_A100{
    return [UIColor fromHexValue:0xf4ff81];
}

+ (UIColor *)md_lime_A200{
    return [UIColor fromHexValue:0xeeff41];
}

+ (UIColor *)md_lime_A400{
    return [UIColor fromHexValue:0xc6ff00];
}

+ (UIColor *)md_lime_A700{
    return [UIColor fromHexValue:0xaeea00];
}

+ (UIColor *)md_yellow_50{
    return [UIColor fromHexValue:0xfffde7];
}

+ (UIColor *)md_yellow_100{
    return [UIColor fromHexValue:0xfff9c4];
}

+ (UIColor *)md_yellow_200{
    return [UIColor fromHexValue:0xfff59d];
}

+ (UIColor *)md_yellow_300{
    return [UIColor fromHexValue:0xfff176];
}

+ (UIColor *)md_yellow_400{
    return [UIColor fromHexValue:0xffee58];
}

+ (UIColor *)md_yellow_500{
    return [UIColor fromHexValue:0xffeb3b];
}

+ (UIColor *)md_yellow_600{
    return [UIColor fromHexValue:0xfdd835];
}

+ (UIColor *)md_yellow_700{
    return [UIColor fromHexValue:0xfbc02d];
}

+ (UIColor *)md_yellow_800{
    return [UIColor fromHexValue:0xf9a825];
}

+ (UIColor *)md_yellow_900{
    return [UIColor fromHexValue:0xf57f17];
}

+ (UIColor *)md_yellow_A100{
    return [UIColor fromHexValue:0xffff8d];
}

+ (UIColor *)md_yellow_A200{
    return [UIColor fromHexValue:0xffff00];
}

+ (UIColor *)md_yellow_A400{
    return [UIColor fromHexValue:0xffea00];
}

+ (UIColor *)md_yellow_A700{
    return [UIColor fromHexValue:0xffd600];
}

+ (UIColor *)md_amber_50{
    return [UIColor fromHexValue:0xfff8e1];
}

+ (UIColor *)md_amber_100{
    return [UIColor fromHexValue:0xffecb3];
}

+ (UIColor *)md_amber_200{
    return [UIColor fromHexValue:0xffe082];
}

+ (UIColor *)md_amber_300{
    return [UIColor fromHexValue:0xffd54f];
}

+ (UIColor *)md_amber_400{
    return [UIColor fromHexValue:0xffca28];
}

+ (UIColor *)md_amber_500{
    return [UIColor fromHexValue:0xffc107];
}

+ (UIColor *)md_amber_600{
    return [UIColor fromHexValue:0xffb300];
}

+ (UIColor *)md_amber_700{
    return [UIColor fromHexValue:0xffa000];
}

+ (UIColor *)md_amber_800{
    return [UIColor fromHexValue:0xff8f00];
}

+ (UIColor *)md_amber_900{
    return [UIColor fromHexValue:0xff6f00];
}

+ (UIColor *)md_amber_A100{
    return [UIColor fromHexValue:0xffe57f];
}

+ (UIColor *)md_amber_A200{
    return [UIColor fromHexValue:0xffd740];
}

+ (UIColor *)md_amber_A400{
    return [UIColor fromHexValue:0xffc400];
}

+ (UIColor *)md_amber_A700{
    return [UIColor fromHexValue:0xffab00];
}

+ (UIColor *)md_orange_50{
    return [UIColor fromHexValue:0xfff3e0];
}

+ (UIColor *)md_orange_100{
    return [UIColor fromHexValue:0xffe0b2];
}

+ (UIColor *)md_orange_200{
    return [UIColor fromHexValue:0xffcc80];
}

+ (UIColor *)md_orange_300{
    return [UIColor fromHexValue:0xffb74d];
}

+ (UIColor *)md_orange_400{
    return [UIColor fromHexValue:0xffa726];
}

+ (UIColor *)md_orange_500{
    return [UIColor fromHexValue:0xff9800];
}

+ (UIColor *)md_orange_600{
    return [UIColor fromHexValue:0xfb8c00];
}

+ (UIColor *)md_orange_700{
    return [UIColor fromHexValue:0xf57c00];
}

+ (UIColor *)md_orange_800{
    return [UIColor fromHexValue:0xef6c00];
}

+ (UIColor *)md_orange_900{
    return [UIColor fromHexValue:0xe65100];
}

+ (UIColor *)md_orange_A100{
    return [UIColor fromHexValue:0xffd180];
}

+ (UIColor *)md_orange_A200{
    return [UIColor fromHexValue:0xffab40];
}

+ (UIColor *)md_orange_A400{
    return [UIColor fromHexValue:0xff9100];
}

+ (UIColor *)md_orange_A700{
    return [UIColor fromHexValue:0xff6d00];
}

+ (UIColor *)md_deep_orange_50{
    return [UIColor fromHexValue:0xfbe9e7];
}

+ (UIColor *)md_deep_orange_100{
    return [UIColor fromHexValue:0xffccbc];
}

+ (UIColor *)md_deep_orange_200{
    return [UIColor fromHexValue:0xffab91];
}

+ (UIColor *)md_deep_orange_300{
    return [UIColor fromHexValue:0xff8a65];
}

+ (UIColor *)md_deep_orange_400{
    return [UIColor fromHexValue:0xff7043];
}

+ (UIColor *)md_deep_orange_500{
    return [UIColor fromHexValue:0xff5722];
}

+ (UIColor *)md_deep_orange_600{
    return [UIColor fromHexValue:0xf4511e];
}

+ (UIColor *)md_deep_orange_700{
    return [UIColor fromHexValue:0xe64a19];
}

+ (UIColor *)md_deep_orange_800{
    return [UIColor fromHexValue:0xd84315];
}

+ (UIColor *)md_deep_orange_900{
    return [UIColor fromHexValue:0xbf360c];
}

+ (UIColor *)md_deep_orange_A100{
    return [UIColor fromHexValue:0xff9e80];
}

+ (UIColor *)md_deep_orange_A200{
    return [UIColor fromHexValue:0xff6e40];
}

+ (UIColor *)md_deep_orange_A400{
    return [UIColor fromHexValue:0xff3d00];
}

+ (UIColor *)md_deep_orange_A700{
    return [UIColor fromHexValue:0xdd2c00];
}

+ (UIColor *)md_brown_50{
    return [UIColor fromHexValue:0xefebe9];
}

+ (UIColor *)md_brown_100{
    return [UIColor fromHexValue:0xd7ccc8];
}

+ (UIColor *)md_brown_200{
    return [UIColor fromHexValue:0xbcaaa4];
}

+ (UIColor *)md_brown_300{
    return [UIColor fromHexValue:0xa1887f];
}

+ (UIColor *)md_brown_400{
    return [UIColor fromHexValue:0x8d6e63];
}

+ (UIColor *)md_brown_500{
    return [UIColor fromHexValue:0x795548];
}

+ (UIColor *)md_brown_600{
    return [UIColor fromHexValue:0x6d4c41];
}

+ (UIColor *)md_brown_700{
    return [UIColor fromHexValue:0x5d4037];
}

+ (UIColor *)md_brown_800{
    return [UIColor fromHexValue:0x4e342e];
}

+ (UIColor *)md_brown_900{
    return [UIColor fromHexValue:0x3e2723];
}

+ (UIColor *)md_grey_50{
    return [UIColor fromHexValue:0xfafafa];
}

+ (UIColor *)md_grey_100{
    return [UIColor fromHexValue:0xf5f5f5];
}

+ (UIColor *)md_grey_200{
    return [UIColor fromHexValue:0xeeeeee];
}

+ (UIColor *)md_grey_300{
    return [UIColor fromHexValue:0xe0e0e0];
}

+ (UIColor *)md_grey_400{
    return [UIColor fromHexValue:0xbdbdbd];
}

+ (UIColor *)md_grey_500{
    return [UIColor fromHexValue:0x9e9e9e];
}

+ (UIColor *)md_grey_600{
    return [UIColor fromHexValue:0x757575];
}

+ (UIColor *)md_grey_700{
    return [UIColor fromHexValue:0x616161];
}

+ (UIColor *)md_grey_800{
    return [UIColor fromHexValue:0x424242];
}

+ (UIColor *)md_grey_900{
    return [UIColor fromHexValue:0x212121];
}

+ (UIColor *)md_black_1000{
    return [UIColor fromHexValue:0x000000];
}

+ (UIColor *)md_white_1000{
    return [UIColor fromHexValue:0xffffff];
}

+ (UIColor *)md_blue_grey_50{
    return [UIColor fromHexValue:0xeceff1];
}

+ (UIColor *)md_blue_grey_100{
    return [UIColor fromHexValue:0xcfd8dc];
}

+ (UIColor *)md_blue_grey_200{
    return [UIColor fromHexValue:0xb0bec5];
}

+ (UIColor *)md_blue_grey_300{
    return [UIColor fromHexValue:0x90a4ae];
}

+ (UIColor *)md_blue_grey_400{
    return [UIColor fromHexValue:0x78909c];
}

+ (UIColor *)md_blue_grey_500{
    return [UIColor fromHexValue:0x607d8b];
}

+ (UIColor *)md_blue_grey_600{
    return [UIColor fromHexValue:0x546e7a];
}

+ (UIColor *)md_blue_grey_700{
    return [UIColor fromHexValue:0x455a64];
}

+ (UIColor *)md_blue_grey_800{
    return [UIColor fromHexValue:0x37474f];
}

+ (UIColor *)md_blue_grey_900{
    return [UIColor fromHexValue:0x263238];
}

@end