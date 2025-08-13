// import 'package:flutter/material.dart';

// enum PriceFilterType { range, average, above }

// final class Currency {
//   static final gbp = Currency(code: "GBP");

//   final String code;

//   Currency({required this.code});

//   String? get sign {
//     if (code == Currency.gbp.code) {
//       return "£";
//     } else {
//       return null;
//     }
//   }
// }

// class PriceFilter {
//   final PriceFilterType type;
//   final double? minPrice;
//   final double? maxPrice;
//   final double? targetPrice; // For average or above
//   final Currency? currency;

//   PriceFilter({
//     required this.type,
//     this.minPrice,
//     this.maxPrice,
//     this.targetPrice,
//     this.currency,
//   });

//   @override
//   String toString() {
//     final currencySign = currency?.sign ?? Currency.gbp.sign ?? "£";
//     switch (type) {
//       case PriceFilterType.range:
//         return 'Range: $currencySign${minPrice?.toStringAsFixed(0)} - $currencySign${maxPrice?.toStringAsFixed(0)}';
//       case PriceFilterType.average:
//         return 'Around: $currencySign${targetPrice?.toStringAsFixed(0)}';
//       case PriceFilterType.above:
//         return 'Above: $currencySign${targetPrice?.toStringAsFixed(0)}';
//     }
//   }

//   String get toSavableString {
//     switch (type) {
//       case PriceFilterType.range:
//         return 'Range - ${minPrice?.toStringAsFixed(0)} - ${maxPrice?.toStringAsFixed(0)}';
//       case PriceFilterType.average:
//         return 'Around - ${targetPrice?.toStringAsFixed(0)}';
//       case PriceFilterType.above:
//         return 'Above - ${targetPrice?.toStringAsFixed(0)}';
//     }
//   }
// }

// class PriceSelectorWidget extends StatefulWidget {
//   final Function(PriceFilter) onPriceChanged;
//   final double minValue;
//   final double maxValue;
//   final PriceFilter? initialFilter;

//   const PriceSelectorWidget({
//     super.key,
//     required this.onPriceChanged,
//     this.minValue = 0,
//     this.maxValue = 1000,
//     this.initialFilter,
//   });

//   @override
//   State<PriceSelectorWidget> createState() => _PriceSelectorWidgetState();
// }

// class _PriceSelectorWidgetState extends State<PriceSelectorWidget> {
//   PriceFilterType _selectedType = PriceFilterType.range;
//   RangeValues _rangeValues = const RangeValues(0, 1000);
//   double _singleValue = 500;

//   @override
//   void initState() {
//     super.initState();
//     _rangeValues = RangeValues(widget.minValue, widget.maxValue);
//     _singleValue = (widget.minValue + widget.maxValue) / 2;

//     if (widget.initialFilter != null) {
//       _selectedType = widget.initialFilter!.type;
//       switch (_selectedType) {
//         case PriceFilterType.range:
//           _rangeValues = RangeValues(
//             widget.initialFilter!.minPrice ?? widget.minValue,
//             widget.initialFilter!.maxPrice ?? widget.maxValue,
//           );
//           break;
//         case PriceFilterType.average:
//         case PriceFilterType.above:
//           _singleValue = widget.initialFilter!.targetPrice ?? _singleValue;
//           break;
//       }
//     }
//   }

//   void _updateFilter() {
//     PriceFilter filter;
//     switch (_selectedType) {
//       case PriceFilterType.range:
//         filter = PriceFilter(
//           type: _selectedType,
//           minPrice: _rangeValues.start,
//           maxPrice: _rangeValues.end,
//         );
//         break;
//       case PriceFilterType.average:
//       case PriceFilterType.above:
//         filter = PriceFilter(type: _selectedType, targetPrice: _singleValue);
//         break;
//     }
//     widget.onPriceChanged(filter);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Price Filter', style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 16),

//             // Price filter type selector
//             Wrap(
//               spacing: 8,
//               children: [
//                 ChoiceChip(
//                   label: const Text('Price Range'),
//                   selected: _selectedType == PriceFilterType.range,
//                   onSelected: (selected) {
//                     if (selected) {
//                       setState(() {
//                         _selectedType = PriceFilterType.range;
//                       });
//                       _updateFilter();
//                     }
//                   },
//                 ),
//                 ChoiceChip(
//                   label: const Text('Around Price'),
//                   selected: _selectedType == PriceFilterType.average,
//                   onSelected: (selected) {
//                     if (selected) {
//                       setState(() {
//                         _selectedType = PriceFilterType.average;
//                       });
//                       _updateFilter();
//                     }
//                   },
//                 ),
//                 ChoiceChip(
//                   label: const Text('Above Price'),
//                   selected: _selectedType == PriceFilterType.above,
//                   onSelected: (selected) {
//                     if (selected) {
//                       setState(() {
//                         _selectedType = PriceFilterType.above;
//                       });
//                       _updateFilter();
//                     }
//                   },
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Price slider(s)
//             if (_selectedType == PriceFilterType.range) ...[
//               Text(
//                 'Price Range: \$${_rangeValues.start.round()} - \$${_rangeValues.end.round()}',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               RangeSlider(
//                 values: _rangeValues,
//                 min: widget.minValue,
//                 max: widget.maxValue,
//                 divisions: 50,
//                 labels: RangeLabels(
//                   '\$${_rangeValues.start.round()}',
//                   '\$${_rangeValues.end.round()}',
//                 ),
//                 onChanged: (values) {
//                   setState(() {
//                     _rangeValues = values;
//                   });
//                 },
//                 onChangeEnd: (values) {
//                   _updateFilter();
//                 },
//               ),
//             ] else ...[
//               Text(
//                 '${_selectedType == PriceFilterType.average ? 'Around' : 'Above'}: \$${_singleValue.round()}',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               Slider(
//                 value: _singleValue,
//                 min: widget.minValue,
//                 max: widget.maxValue,
//                 divisions: 50,
//                 label: '\$${_singleValue.round()}',
//                 onChanged: (value) {
//                   setState(() {
//                     _singleValue = value;
//                   });
//                 },
//                 onChangeEnd: (value) {
//                   _updateFilter();
//                 },
//               ),
//             ],

//             const SizedBox(height: 8),

//             // Current selection display
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primaryContainer,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.price_check,
//                     size: 16,
//                     color: Theme.of(context).colorScheme.onPrimaryContainer,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     _getCurrentFilterText(),
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.onPrimaryContainer,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getCurrentFilterText() {
//     switch (_selectedType) {
//       case PriceFilterType.range:
//         return 'Range: \$${_rangeValues.start.round()} - \$${_rangeValues.end.round()}';
//       case PriceFilterType.average:
//         return 'Around: \$${_singleValue.round()}';
//       case PriceFilterType.above:
//         return 'Above: \$${_singleValue.round()}';
//     }
//   }
// }
