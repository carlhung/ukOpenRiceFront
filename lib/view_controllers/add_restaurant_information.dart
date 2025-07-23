import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:ukopenrice/models/resturant_info.dart';
import 'package:ukopenrice/models/http_client.dart';
import 'package:ukopenrice/routes.dart';

class AddResturantInformation extends StatefulWidget {
  const AddResturantInformation({super.key});

  @override
  State<AddResturantInformation> createState() =>
      _AddResturantInformationState();
}

final class _AddResturantInformationState
    extends State<AddResturantInformation> {
  final httpClient = Httpclient.shared;
  final restuarantChineseNameCtrllor = TextEditingController();
  final restuarantEnglishNameCtrllor = TextEditingController();
  final cuisineCtrllor = TextEditingController();
  String otherCuisine = '';
  final descriptionCtrllor = TextEditingController();
  final addressCtrllor = TextEditingController();
  final phoneCtrllor = TextEditingController();
  final webCtrllor = TextEditingController();
  final facebookCtrllor = TextEditingController();
  final instagramCtrllor = TextEditingController();
  final emailCtrllor = TextEditingController();
  final openingHoursCtrllor = TextEditingController();
  bool _accessReservation = false;
  Set<Payment> selectedPayments = {};
  bool _takeaway = false;
  bool _delivery = false;
  final priceRangeCtrllor = TextEditingController();
  final extraInfoCtrllor = TextEditingController();

  ResturantInfo? _createResturantInfo() {
    if (restuarantEnglishNameCtrllor.text.isNotEmpty &&
        descriptionCtrllor.text.isNotEmpty &&
        addressCtrllor.text.isNotEmpty &&
        phoneCtrllor.text.isNotEmpty &&
        emailCtrllor.text.isNotEmpty &&
        openingHoursCtrllor.text.isNotEmpty &&
        selectedPayments.isNotEmpty &&
        priceRangeCtrllor.text.isNotEmpty) {
      if (cuisineCtrllor.text.isEmpty) {
        return null;
      }
      final String cuisine;
      if (cuisineCtrllor.text == Cuisine.otherCuisine.name) {
        if (otherCuisine.isNotEmpty) {
          cuisine = otherCuisine;
        } else {
          return null;
        }
      } else {
        cuisine = cuisineCtrllor.text;
      }

      return ResturantInfo(
        restuarantChineseName: restuarantChineseNameCtrllor.text,
        restuarantEnglishName: restuarantEnglishNameCtrllor.text,
        cuisine: cuisine,
        description: descriptionCtrllor.text,
        address: addressCtrllor.text,
        phone: phoneCtrllor.text,
        web: webCtrllor.text,
        facebook: facebookCtrllor.text,
        instagram: instagramCtrllor.text,
        email: emailCtrllor.text,
        openingHours: openingHoursCtrllor.text,
        accessReservation: _accessReservation,
        selectedPayments: selectedPayments,
        takeaway: _takeaway,
        delivery: _delivery,
        priceRange: priceRangeCtrllor.text,
        extraInfo: extraInfoCtrllor.text,
      );
    } else {
      return null;
    }
  }

  void _showCuisinePicker(BuildContext context) {
    Picker(
      adapter: PickerDataAdapter<String>(
        pickerData: Cuisine.allCuisines.map((cuisine) => cuisine.name).toList(),
      ),
      title: Text('Select an Option'),
      onConfirm: (Picker picker, List<int> value) {
        setState(() {
          cuisineCtrllor.text = picker.getSelectedValues().first;
        });
      },
    ).showModal(context);
  }

  Widget _createTickBox(
    String title,
    bool defaultValue,
    void Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Text("$title:"),
        Checkbox(
          value: defaultValue,
          onChanged: (value) {
            setState(() {
              onChanged(value ?? false);
            });
          },
        ),
      ],
    );
  }

  Widget _createTextView(TextEditingController controller, String labelText) {
    return _createTextField(
      controller,
      labelText,
      keyboardType: TextInputType.multiline,
      maxLines: 3,
    );
  }

  Widget _createTextField(
    TextEditingController controller,
    String labelText, {
    TextInputType? keyboardType,
    int maxLines = 1,
    int? minLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      textAlignVertical: keyboardType == TextInputType.multiline
          ? const TextAlignVertical(y: -1)
          : null,
      decoration: InputDecoration(
        alignLabelWithHint: keyboardType == TextInputType.multiline
            ? true
            : null,
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      obscureText: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              _createTextField(restuarantChineseNameCtrllor, "Name in Chinese"),
              _createTextField(
                restuarantEnglishNameCtrllor,
                "Name in English (Required)",
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10,
                children: [
                  Text(
                    'Cuisine Type: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: TextField(
                      controller: cuisineCtrllor,
                      decoration: InputDecoration(
                        labelText: "Cuisine (Required)",
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _showCuisinePicker(context),
                    ),
                  ),
                ],
              ),
              if (cuisineCtrllor.text == Cuisine.otherCuisine.name)
                TextField(
                  decoration: InputDecoration(
                    labelText: "Cuisine (Required)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {
                    otherCuisine = value;
                  }),
                ),

              _createTextView(descriptionCtrllor, "description (Required)"),
              _createTextField(addressCtrllor, "Address (Required)"),
              _createTextField(
                phoneCtrllor,
                "Phone Number (Required)",
                keyboardType: TextInputType.phone,
              ),
              _createTextField(webCtrllor, "Website"),
              _createTextField(facebookCtrllor, "Facebook"),
              _createTextField(instagramCtrllor, "Instagram"),
              _createTextField(
                emailCtrllor,
                "Email (Required)",
                keyboardType: TextInputType.emailAddress,
              ),
              _createTextView(openingHoursCtrllor, "Opening Hours (Required)"),
              _createTickBox("Access Reservation", _accessReservation, (value) {
                _accessReservation = value;
              }),
              Text("Payment methods (Required): "),
              MultiSelectContainer(
                maxSelectableCount: null,
                items: Payment.allPayments.map((payment) {
                  return MultiSelectCard(
                    value: payment.name,
                    label: payment.name,
                    // selectedColor: Colors.blue,
                    // unselectedColor: Colors.grey,
                  );
                }).toList(),
                // onMaximumSelected: (allSelectedItems, selectedItem) {
                //   // CustomSnackBar.showInSnackBar('The limit has been reached', context);
                // },
                onChange: (allSelectedItems, selectedItem) {
                  setState(() {
                    selectedPayments = allSelectedItems
                        .map((item) => Payment(name: item))
                        .toSet();
                  });
                },
              ),
              _createTickBox("takeaway", _takeaway, (value) {
                _takeaway = value;
              }),
              _createTickBox("delivery", _delivery, (value) {
                _delivery = value;
              }),
              _createTextField(priceRangeCtrllor, "Price Range (Required)"),
              _createTextView(extraInfoCtrllor, "Extra Information"),
              ElevatedButton(
                onPressed: () async {
                  final info = _createResturantInfo();
                  if (info != null) {
                    try {
                      await httpClient.submitRestaurantInformation(info);
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          Routes.uploadPhotoScreen,
                          arguments: info.restuarantEnglishName,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showErrorOnSnackBar(context, e);
                      }
                    }
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 1.餐廳基本資料
// 餐廳名稱（中英文）
// 餐廳分類（例如：中餐、日式、火鍋、茶餐廳…）
// 餐廳簡介（可多語言）
// 地址（建議接 Google Map API，自動地圖）
// 聯絡電話
// 網站 / Facebook / IG
// 電郵

// 2.餐廳營業資訊
// 營業時間（星期一至日）
// 是否接受訂座
// 是否接受信用卡
// 是否提供外賣 / 自取
// 價格範圍（$ / $$ / $$$）
// 特別日子／公眾假期營業資訊

// 3,餐廳圖片
// 封面圖（橫向）
// 圖片集（可多張）
// 餐牌圖片（如有）
// 建議圖片上傳功能支援「拖拉上傳 + 自動壓縮尺寸」

// 4.⁠ ⁠餐廳狀態管理
// 是否啟用／下架
// 是否推薦（如放首頁）
// 是否付費商戶（可結合付費廣告）

// 5.⁠ ⁠用戶評論管理
// 查看用戶評論／星級
// 管理違規留言（刪除、封鎖）
// 回覆評論（如有商戶登入）
