import 'package:flutter/material.dart';
import 'package:ukopenrice/helpers.dart';
import 'package:ukopenrice/l10n/app_localizations.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:ukopenrice/models/resturant_info.dart';
import 'package:ukopenrice/models/http_client.dart';
import 'package:ukopenrice/routes.dart';
import 'package:ukopenrice/view_controllers/open_hours_selector.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RestaurantUploadForm extends StatefulWidget {
  const RestaurantUploadForm({super.key});

  @override
  State<RestaurantUploadForm> createState() => _RestaurantUploadFormState();
}

final class _RestaurantUploadFormState extends State<RestaurantUploadForm> {
  final httpClient = Httpclient.shared;
  final ImagePicker picker = ImagePicker();
  List<XFile> _selectedImages = [];
  XFile? _profileImage;

  // Restaurant information controllers
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

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Text(
          'Profile Image (Required)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 10),
        if (_profileImage != null)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.file(File(_profileImage!.path), fit: BoxFit.cover),
          ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final selectedImage = await picker.pickImage(
              source: ImageSource.gallery,
            );
            setState(() {
              _profileImage = selectedImage;
            });
          },
          child: Text("Select Profile Image"),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      children: [
        Text(
          'Restaurant Photos',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 10),
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 300,
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _selectedImages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.file(
                    File(_selectedImages[index].path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final selectedImage = await picker.pickMultiImage();
                setState(() {
                  _selectedImages = selectedImage;
                });
              },
              child: Text("Select Images"),
            ),
          ],
        ),
      ],
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
              // Restaurant Information Section
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
                  );
                }).toList(),
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
              _buildDropdown("Price Range (Required)", createPriceRangeList()),
              _createTextView(extraInfoCtrllor, "Extra Information"),

              // Profile Image Section
              _buildProfileImageSection(),
              SizedBox(height: 20),

              // Image Upload Section
              _buildImageUploadSection(),

              ElevatedButton(
                onPressed: () async {
                  final info = await _createResturantInfo();
                  if (info != null && _profileImage != null) {
                    try {
                      final wrappedMap = MapEncodable(value: info.toJson());
                      await httpClient.submitRestaurantInformation([
                        BodyPair(value: EncodableBodyValue(wrappedMap)),
                        BodyPair(
                          value: ImagesBodyValue(
                            [XfileWithName(_profileImage!, name: 'profile')] +
                                _selectedImages
                                    .map((elm) => XfileWithName(elm))
                                    .toList(),
                          ),
                        ),
                        // BodyPair(
                        //   value: ImagesBodyValue.fromXFiles(_selectedImages),
                        // ),
                      ]);
                      // example:
                      // final wrappedMap = MapEncodable(value: _formData);
                      // await httpClient.postReview([
                      //   BodyPair(value: EncodableBodyValue(wrappedMap)),
                      //   BodyPair(
                      //     value: ImagesBodyValue.fromXFiles(_selectedImages),
                      //   ),
                      // ]);

                      if (context.mounted) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(Routes.restaurantInputMode),
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
                child: Text("Submit Restaurant & Photos"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class RestaurantName extends Encodable {
  final String name;
  RestaurantName({required this.name});

  @override
  Map<String, dynamic> toJson() => {"restaurant name": name};
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
