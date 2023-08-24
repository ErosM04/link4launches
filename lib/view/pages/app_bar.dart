import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom class used to create a customized [AppBar].
class L4LAppBar {
  /// The title of the appbar.
  final String title;

  /// The action of the appbar. Ususally MenuButtons
  final List<Widget> actions;

  /// Whether show the pre-defined pop-up menu.
  final bool popUpMenu;

  /// The list of Icons to show in the pop up menu
  final List<IconData> iconsListPopUp;

  /// The list of texts to show in the pop up menu
  final List<String> titlesListPopUp;

  /// The list of link to use in the pop up menu
  final List<String> linksListPopUp;

  /// Custom [AppBar].
  const L4LAppBar({
    this.title = 'Link4Launches',
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

  /// Allows to build the [SliverAppBar] widget to use.
  SliverAppBar buildAppBar() => SliverAppBar(
        title: Text(title),
        actions: _buildActions(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(14),
          ),
        ),
      );

  /// Creates all the clickable icons on the right side of the appbar.
  List<Widget> _buildActions() {
    var list = List<Widget>.from(actions, growable: true);

    if (popUpMenu) {
      list.add(_getPopUpMenuButton());
    }

    return list;
  }

  /// Creates the pop-up menu
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

  /// Creates the single tile of the pop-up menu.
  /// ``PAY ATTENTION!! Uses a deprecated System API``
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
