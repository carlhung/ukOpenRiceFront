import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:ukopenrice/models/resturant_info.dart';
import 'package:ukopenrice/models/http_client.dart';
import 'package:ukopenrice/routes.dart';
import 'package:ukopenrice/view_controllers/open_hours_selector.dart';
// import 'package:ukopenrice/view_controllers/price_selector.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

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
  final cityCtrllor = TextEditingController();
  final phoneCtrllor = TextEditingController();
  final mapCtrllor = TextEditingController();
  final webCtrllor = TextEditingController();
  final facebookCtrllor = TextEditingController();
  final instagramCtrllor = TextEditingController();
  final emailCtrllor = TextEditingController();
  bool _accessReservation = false;
  Set<Payment> selectedPayments = {};
  bool _takeaway = false;
  bool _delivery = false;
  // final priceRangeCtrllor = TextEditingController();
  // PriceFilter? _currentFilter;
  String priceRange = "";
  final extraInfoCtrllor = TextEditingController();

  Map<String, List<TimeSlot>> schedule =
      OpeningHoursSelectorState.defaultSchedule;

  @override
  void dispose() {
    for (final vc in [
      restuarantChineseNameCtrllor,
      restuarantEnglishNameCtrllor,
      cuisineCtrllor,
      descriptionCtrllor,
      addressCtrllor,
      cityCtrllor,
      phoneCtrllor,
      mapCtrllor,
      webCtrllor,
      facebookCtrllor,
      instagramCtrllor,
      emailCtrllor,
      extraInfoCtrllor,
    ]) {
      vc.dispose();
    }
    super.dispose();
  }

  Future<ResturantInfo?> _createResturantInfo() async {
    if (restuarantEnglishNameCtrllor.text.isNotEmpty &&
        descriptionCtrllor.text.isNotEmpty &&
        addressCtrllor.text.isNotEmpty &&
        cityCtrllor.text.isNotEmpty &&
        mapCtrllor.text.isNotEmpty &&
        phoneCtrllor.text.isNotEmpty &&
        openHoursTosavableString().isNotEmpty &&
        isScheduleInOrder() &&
        // (_currentFilter?.toSavableString.isNotEmpty ?? false) &&
        priceRange.isNotEmpty &&
        selectedPayments.isNotEmpty) {
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

      final timezone = await _getTimezone();

      return ResturantInfo(
        restuarantChineseName: restuarantChineseNameCtrllor.text.trim(),
        restuarantEnglishName: restuarantEnglishNameCtrllor.text.trim(),
        cuisine: cuisine.trim(),
        description: descriptionCtrllor.text.trim(),
        address: addressCtrllor.text.trim(),
        city: cityCtrllor.text.trim(),
        phone: phoneCtrllor.text.trim(),
        map: mapCtrllor.text.trim(),
        web: webCtrllor.text.trim(),
        facebook: facebookCtrllor.text.trim(),
        instagram: instagramCtrllor.text.trim(),
        email: emailCtrllor.text.trim(),
        openingHours: openHoursTosavableString().trim(),
        accessReservation: _accessReservation,
        selectedPayments: selectedPayments,
        takeaway: _takeaway,
        delivery: _delivery,
        // priceRange: _currentFilter!.toSavableString.trim(),
        // currencyCode: _currentFilter?.currency?.code ?? Currency.gbp.code,
        priceRange: priceRange,
        currencyCode: "GBP",
        extraInfo: extraInfoCtrllor.text.trim(),
        timezone: timezone,
      );
    } else {
      return null;
    }
  }

  String openHoursTosavableString() {
    return OpeningHoursSelectorState.toLines(schedule).join("\n");
  }

  bool isScheduleInOrder() {
    for (final elm in schedule.values) {
      if (!elm.areTimeSlotsInOrder()) return false;
    }
    return true;
  }

  void _showCityPicker(BuildContext context) {
    Picker(
      adapter: PickerDataAdapter<String>(pickerData: cities),
      title: Text('Select a city'),
      onConfirm: (Picker picker, List<int> value) {
        setState(() {
          cityCtrllor.text = picker.getSelectedValues().first;
        });
      },
    ).showModal(context);
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

              TextField(
                controller: cityCtrllor,
                decoration: InputDecoration(
                  labelText: "City (Required)",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _showCityPicker(context),
              ),

              _createTextField(mapCtrllor, "Map (Required)"),
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
              Text(
                'Open Hours:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              OpeningHoursSelector(
                onHoursChanged: (timeSlots) {
                  setState(() {
                    schedule = timeSlots;
                  });
                },
              ),
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
              // _createTextField(priceRangeCtrllor, "Price Range (Required)"),
              // Text("Price Range (Required):"),
              // PriceSelectorWidget(
              //   onPriceChanged: (filter) {
              //     setState(() {
              //       _currentFilter = filter;
              //     });
              //   },
              // ),
              _buildDropdown("Price Range (Required)", createPriceRangeList()),
              _createTextView(extraInfoCtrllor, "Extra Information"),
              ElevatedButton(
                onPressed: () async {
                  final info = await _createResturantInfo();
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
                  } else {
                    if (context.mounted) {
                      showErrorOnSnackBar(
                        context,
                        "either missing required fields or wrong open hours",
                      );
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

  Widget _buildDropdown(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: options
          .map((opt) => DropdownMenuItem(value: opt, child: Text("£$opt")))
          .toList(),
      onChanged: (value) => priceRange = value ?? "",
    );
  }

  Future<String> _getTimezone() async {
    return await FlutterTimezone.getLocalTimezone();
  }
}

// https://www.gov.uk/government/publications/list-of-cities/list-of-cities-html#fn:1
List<String> cities =
    """
Bath
Birmingham
Bradford
Brighton & Hove
Bristol
Cambridge
Canterbury
Carlisle
Chelmsford
Chester
Chichester
Colchester
Coventry
Derby
Doncaster
Durham
Ely
Exeter
Gloucester
Hereford
Kingston-upon-Hull
Lancaster
Leeds
Leicester
Lichfield
Lincoln
Liverpool
London
Manchester
Milton Keynes
Newcastle-upon-Tyne
Norwich
Nottingham
Oxford
Peterborough
Plymouth
Portsmouth
Preston
Ripon
Salford
Salisbury
Sheffield
Southampton
Southend-on-Sea
St Albans
Stoke on Trent
Sunderland
Truro
Wakefield
Wells
Westminster
Winchester
Wolverhampton
Worcester
York
Armagh
Bangor
Belfast
Lisburn
Londonderry
Newry
Aberdeen
Dundee
Dunfermline
Edinburgh
Glasgow
Inverness
Perth
Stirling
Bangor
Cardiff
Newport
St Asaph
St Davids
Swansea
Wrexham
Douglas
Overseas Territories
Hamilton
City of Gibraltar
Stanley
Jamestown
"""
        .split("\n")
        .toList();

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
