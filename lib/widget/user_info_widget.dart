import 'package:dwpn_3dcnc_rooster/data/app_data.dart';
import 'package:dwpn_3dcnc_rooster/event/app_events.dart';
import 'package:dwpn_3dcnc_rooster/model/app_models.dart';
import 'package:dwpn_3dcnc_rooster/util/app_mixin.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget with AppMixin {
  UserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: c.h1 * 2,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildUserNameRow(), _logOutButton(context)]),
    );
  }

  User _user() => AppData.instance.getUser();

  Widget _buildUserNameRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const IconButton(
          color: Colors.blue,
          icon: Icon(Icons.person),
          onPressed: null,
        ),
        Text(_user().fullname),
      ],
    );
  }

  Widget _logOutButton(BuildContext context) {
    return TextButton(
      child: const Text('Log out'),
      onPressed: () {
        AppEvents.fireLogOutEvent();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }
}
