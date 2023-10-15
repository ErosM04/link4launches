import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom class used to create a customized [SliverAppBar].
class L4LAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title of the appbar.
  final String title;

  /// The list of buttons of the appbar, usually [IconButton] widgets.
  final List<Widget> actions;

  /// Whether to show the pop-up menu.
  final bool showPopupMenu;

  /// The list of Icons to show in the pop-up menu (it ontains predefined elements).
  final List<IconData> iconsListPopUp;

  /// The list of texts to show in the pop-up menu (it ontains predefined elements).
  final List<String> titlesListPopUp;

  /// The list of link to use in the pop-up menu (it ontains predefined elements).
  final List<String> linksListPopUp;

  const L4LAppBar({
    super.key,
    this.title = 'Link4Launches',
    this.actions = const [],
    this.showPopupMenu = true,
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

  @override
  Widget build(BuildContext context) => SliverAppBar(
        title: Text(title),
        actions: _buildActions(),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(14),
          ),
        ),
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Creates all the clickable icons on the right side of the appbar.
  /// If ``[showPopupMenu]`` is false, the pop-up menu is non shown.
  List<Widget> _buildActions() {
    if (showPopupMenu) {
      return List<Widget>.from(
        [...actions, _getPopUpMenuButton()],
        growable: true,
      );
    }
    return List<Widget>.from(actions);
  }

  /// Creates the pop-up menu button.
  PopupMenuButton _getPopUpMenuButton() => PopupMenuButton(
        itemBuilder: (context) => List<PopupMenuItem>.generate(
            titlesListPopUp.length, (index) => _getPopUpMenuTile(index)),
        offset: const Offset(0, 60),
        elevation: 2,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18))),
        onSelected: (value) => launchUrl(Uri.parse(linksListPopUp[value])),
      );

  /// Creates the single tile of the pop-up menu.
  PopupMenuItem _getPopUpMenuTile(int index) => PopupMenuItem(
        value: index,
        child: Row(
          children: [
            Icon(
              iconsListPopUp[index],
              color: _isLightMode() ? Colors.black : null,
            ),
            const SizedBox(width: 10),
            Text(titlesListPopUp[index]),
          ],
        ),
      );

  /// Can be used to know if the device is in dark or light mode, this is used because for the light theme an appbar color icon is specified,
  /// but this has to change when considering the pop-up menu. Only in light mode!
  ///
  /// #### Returns
  /// ``bool`` : true if the device is in light mode.
  bool _isLightMode() =>
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.light;
}
