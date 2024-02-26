import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_helper.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class DeviceInfo extends StatelessWidget with AppMixin {
  final String devicePk;
  late final Device _device;
  DeviceInfo({super.key, required this.devicePk}) {
    _device = AppData.instance.deviceList
        .firstWhere((element) => element.name == devicePk);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: c.w1 * 4,
      height: c.h1 * 7,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildDeviceInfoRow(),
        _showReservationCounts(),
        _showImage()
      ]),
    );
  }

  Widget _buildDeviceInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const IconButton(
          color: Colors.blue,
          icon: Icon(Icons.precision_manufacturing_sharp),
          onPressed: null,
        ),
        Text(_device.description),
      ],
    );
  }

  Widget _showReservationCounts() {
    String text = '';
    text += _getRsvCounts(0);
    text += _getRsvCounts(1);
    return Text(text);
  }

  String _getRsvCounts(int index) {
    SpreadSheet ss = AppData.instance.getSpreadSheetList()[index];
    DateTime dateTime = DateTime(ss.year, ss.month, 1);
    String maand = AppHelper.instance.monthAsString(dateTime);
    int count = _deviceCount(ss);
    String text = 'Aantal reservering voor $maand : $count \n';
    return text;
  }

  int _deviceCount(SpreadSheet ss) {
    List<Reservation> list =
        ss.reservations.where((e) => e.devicePk == devicePk).toList();
    return list.length;
  }

  Widget _showImage() {
    return SizedBox(
        width: c.w1 * 3,
        height: c.h1 * 3,
        child: Image.asset(
          '${devicePk.toLowerCase()}.jpg',
          fit: BoxFit.fill,
        ));
  }
}
