import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:link4launches/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class L4LAppBar {
  final String title;
  final Color color;
  final List<Widget> actions;
  final bool popUpMenu;
  final List<IconData> iconsListPopUp;
  final List<String> titlesListPopUp;
  final List<String> linksListPopUp;

  const L4LAppBar({
    this.title = APP_NAME,
    this.color = MAIN_COLOR,
    this.actions = const [],
    this.popUpMenu = true,
    this.iconsListPopUp = const [
      Icons.rocket,
      Icons.link,
      Icons.code,
    ],
    this.titlesListPopUp = const [
      'Api',
      'L4U',
      'Git',
    ],
    this.linksListPopUp = const [
      'https://thespacedevs.com/llapi',
      'https://www.youtube.com/@link4universe',
      'https://github.com/ErosM04/link4launches'
    ],
  });

  AppBar buildAppBar() => AppBar(
        title: Text(title),
        backgroundColor: color,
        actions: _buildActions(),
      );

  List<Widget> _buildActions() {
    var list = List<Widget>.from(actions, growable: true);

    if (popUpMenu) {
      list.add(_getPopUpMenuButton());
    }

    return list;
  }

  PopupMenuButton _getPopUpMenuButton() {
    List<PopupMenuItem> list = [];
    for (int i = 0; i < titlesListPopUp.length; i++) {
      list.add(_getPopUpMenuTile(i));
    }

    return PopupMenuButton(
      itemBuilder: (context) => list,
      offset: const Offset(0, 60),
      elevation: 2,
      onSelected: (value) => launchUrl(Uri.parse(linksListPopUp[value])),
    );
  }

  PopupMenuItem _getPopUpMenuTile(int index) => PopupMenuItem(
        value: index,
        child: Row(
          children: [
            Icon(
              iconsListPopUp[index],
              color: SchedulerBinding.instance.window.platformBrightness ==
                      Brightness.dark
                  ? Colors.white
                  : const Color.fromARGB(255, 57, 58, 59),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(titlesListPopUp[index]),
          ],
        ),
      );
}
