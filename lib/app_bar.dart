import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

class L4LAppBar {
  final String title;
  final Color color;
  final bool popUpMenu;
  final List<IconData> iconsListPopUp;
  final List<String> titlesListPopUp;
  final List<String> linksListPopUp;

  const L4LAppBar({
    required this.title,
    required this.color,
    required this.popUpMenu,
    required this.iconsListPopUp,
    required this.titlesListPopUp,
    required this.linksListPopUp,
  });

  PopupMenuButton getPopUpMenuButton() {
    if (!popUpMenu) {
      return PopupMenuButton(
        itemBuilder: ((context) => []),
      );
    }

    List<PopupMenuItem> list = [];
    for (int i = 0; i < titlesListPopUp.length; i++) {
      list.add(_getPopUpMenuItem(i));
    }

    return PopupMenuButton(
      itemBuilder: (context) => list,
      offset: const Offset(0, 60),
      elevation: 2,
      onSelected: (value) => launchUrl(Uri.parse(linksListPopUp[value])),
    );
  }

  PopupMenuItem _getPopUpMenuItem(int index) {
    return PopupMenuItem(
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
}
