# Link4Launches - Full Guide
This mobile app📱 can be used to access information about upcoming rocket launches🚀 or latest launches performed by many different companies and agencies like **SpaceX**, **Rocket Lab**, **NASA**, **ESA**...

This is the full guide to the app functionalities. 

### Index

1. [Idea](#idea)
    - [Icon](#icon)
2. [API](#api)
    - [Requests](#requests)
3. [Auto Update](#auto-update)
4. [Interface & Functions](#interface-and-functions)
    - [Home page](#home-page)
        - [AppBar](#appbar)
    - [Launch page](#launch-page)
5. [TODO](#todo)


## Idea
This app was born as a school project and is inspired to the YouTube astronomy channel [link4universe](https://www.youtube.com/@link4universe):star: managed by [Adrian Fartade](https://www.adrianfartade.it/#chi-sono).

### Icon
The icon is inspired to the Telegram channel [L2U Space News](https://t.me/L2USpaceNews) (previously L4U), also managed by Adrian and his crew.

<img src='./readme_images/app-icon.png' width='100'>


## API
The api used is [Launch Library 2](https://thespacedevs.com/llapi), developed by [Go4Liftoff](https://go4liftoff.com/about). The function used is **Launches**, which allows to get a json containing many information about launches from different companies and agency. However the free use of the api is limited up to **15 uses per hour**, so it as the. That is why the app performs a main request for 14 upcoming launches and then for every launch performs another request for more **specific info** (for a maximun amount of 15).

To avoid wasting requests, when the app is recharged or the reload button is pressed only the main request is performed, and the specific info data for every launch is then retrived from the backup file. 
If there are no **specific info** regarding a launch in the backup file a request is performed.

To save more requests, if two or more launches need **specific info** that were already fetched with a previous request (usually because more launches are made by the same comapny) the data are resued to avoid wasting requests.

### Requests
Here some example of request to the API:
- The main request used by the app for upcoming launches list: https://ll.thespacedevs.com/2.2.0/launch/upcoming/?format=json&limit=14
- The default request allows to get a 10 elements list: https://ll.thespacedevs.com/2.2.0/launch/upcoming/?format=json
- The full link with all the customizable parameters: [link](https://ll.thespacedevs.com/2.2.0/launch/upcoming/?agency_launch_attempt_count=&agency_launch_attempt_count__gt=&agency_launch_attempt_count__gte=&agency_launch_attempt_count__lt=&agency_launch_attempt_count__lte=&agency_launch_attempt_count_year=&agency_launch_attempt_count_year__gt=&agency_launch_attempt_count_year__gte=&agency_launch_attempt_count_year__lt=&agency_launch_attempt_count_year__lte=&format=json&location_launch_attempt_count=&location_launch_attempt_count__gt=&location_launch_attempt_count__gte=&location_launch_attempt_count__lt=&location_launch_attempt_count__lte=&location_launch_attempt_count_year=&location_launch_attempt_count_year__gt=&location_launch_attempt_count_year__gte=&location_launch_attempt_count_year__lt=&location_launch_attempt_count_year__lte=&mission__orbit__name=&mission__orbit__name__icontains=&name=&orbital_launch_attempt_count=&orbital_launch_attempt_count__gt=&orbital_launch_attempt_count__gte=&orbital_launch_attempt_count__lt=&orbital_launch_attempt_count__lte=&orbital_launch_attempt_count_year=&orbital_launch_attempt_count_year__gt=&orbital_launch_attempt_count_year__gte=&orbital_launch_attempt_count_year__lt=&orbital_launch_attempt_count_year__lte=&pad_launch_attempt_count=&pad_launch_attempt_count__gt=&pad_launch_attempt_count__gte=&pad_launch_attempt_count__lt=&pad_launch_attempt_count__lte=&pad_launch_attempt_count_year=&pad_launch_attempt_count_year__gt=&pad_launch_attempt_count_year__gte=&pad_launch_attempt_count_year__lt=&pad_launch_attempt_count_year__lte=&r_spacex_api_id=&rocket__configuration__full_name=&rocket__configuration__full_name__icontains=&rocket__configuration__id=&rocket__configuration__manufacturer__name=&rocket__configuration__manufacturer__name__icontains=&rocket__configuration__name=&rocket__spacecraftflight__spacecraft__id=&rocket__spacecraftflight__spacecraft__name=&rocket__spacecraftflight__spacecraft__name__icontains=&slug=&status=1)


## Auto update
Every time the app is loaded a request to the Github API (limited to 60/h) is performed, at the following link: https://api.github.com/repos/ErosM04/link4launches/releases/latest

This url returns a json containing data about the latest **Github release**.

If the version of the app is different from the one of the release, a dialog appears and asks to the user if he/she wants to downalod the new version.

If the user gives his/her consent then a download of the latest app version ``link4launches.apk`` is performed and the file ends up in the ``Downloads`` folder.

Here is the link that allows to download the apk directly from GitHub: https://github.com/ErosM04/link4launches/releases/latest/download/link4launches.apk

Example of the different stages of the update process:
<div align='center'>
    <img src='./readme_images/home page/updater/update_banner_dark.jpg' width='200'>
    <img src='./readme_images/home page/updater/update_banner_light.jpg' width='200'>
</div>
<div align='center'>
    <img src='./readme_images/home page/updater/update_download_started_dark.jpg' width='200'>
    <img src='./readme_images/home page/updater/update_download_started_light.jpg' width='200'>
</div>
<div align='center'>
    <img src='./readme_images/home page/updater/update_download_finished_dark.jpg' width='200'>
    <img src='./readme_images/home page/updater/update_download_finished_light.jpg' width='200'>
</div>

Thanks to the Android buil-in functions, when building an apk file is possible to specify the version, so the new apk file is going to be automatically recognized as an update by Android.

If the app hasn't been updated (despite having downloaded the update), even if the download ``Snackbar`` on the bottom of the screen appears, a new download won't be really performed if the update file in the ``Download`` folder is still there.


## Interface and Functions

### Home page
The home page of the app is the following:

<div align='center'>
    <img src='./readme_images/home page/home_page_dark.jpg' width='200'>
    <img src='./readme_images/home page/home_page_light.jpg' width='200'>
</div>

The list is made by the latest launches (like successful or failed launches [currently not in the image]) followed by all the upcoming launches ordered by launch date. The page can be scrolled to access to the other launches, for a total number of ``14``.

Here is the full page:

<div align='center'>
    <img src='./readme_images/home page/home_page_full_dark.jpg' width='200'>
    <img src='./readme_images/home page/home_page_full_light.jpg' width='200'>
</div>

Every tile of the list contains the name of the launch, the date and his status that can be:
- **GO**: Ready To Go;
- **TBC**: To Be Confirmed - Awaiting official confirmation;
- **TBD**: To Be Defined;
- **SUCCESS**: Launch Successful;
- **FAILURE**: Launch Failed;
- **PARTIAL FAILURE**: Either a Partial Failure or an exceptional event made it impossible to consider the mission a success;
- **IN FLIGHT**: Rocket actually In Flight;
- **ON HOLD**: The launch has been paused, but it can still happen within the launch window.

By clicking on the status icon is possible to show a ``Snackbar`` that will describe the state:

<div align='center'>
    <img src='./readme_images/home page/home_page_go_dark.jpg' width='200'>
    <img src='./readme_images/home page/home_page_go_light.jpg' width='200'>
</div>
<div align='center'>
    <img src='./readme_images/home page/home_page_tbc_dark.jpg' width='200'>
    <img src='./readme_images/home page/home_page_tbc_light.jpg' width='200'>
</div>

#### Appbar
The appbar contains the name of the app followed by 3 buttons:
- **TBD**: used to hide the ``To Be Defined`` results, as often there are many TBD launches which are less important then the others, because they still have to be defined.

<div align='center'>
    <img src='./readme_images/home page/home_page_notbd_dark.jpg' width='200'>
    <img src='./readme_images/home page/home_page_notbd_light.jpg' width='200'>
</div>

- **Recharge**: used to send a request to the api and refresh data;
- **Dropdown-menu**: containg different links to:
    - The [API](https://thespacedevs.com/llapi);
    - The YouTube Channel [Link4Universe](https://www.youtube.com/@link4universe) which inspired the app;
    - The Github project of the app.

<div align='center'>
    <img src='./readme_images/home page/home_page_dropdown_menu_dark.jpg ' width='200'>
    <img src='./readme_images/home page/home_page_dropdown_menu_light.jpg' width='200'>
</div>

### Launch page
By clicking on a tile in the home page, the launch page (info page) is opend. In this page you can find 3 different containers. Note that not every container may be displayed due to the api request limit which can block the requests used to get the details of the launch. The containers are the following:

- The first container contains launch data:
    - an image of the rocket or the payload, loaded with a shimmering loading animation;

    <div align='center'>
        <img src='./readme_images/launch page/launch_page_shimmer_dark.jpg' width='200'>
        <img src='./readme_images/launch page/launch_page_shimmer_light.jpg' width='200'>
    </div>

    - the full name of the launch;
    - the status (that can be clicked to show a ``SnackBar`` with the description);
    - the launch date;
    - the launch time;
    - the description of the mission or the payload;
    - a button with a link to open the pad location on google maps.

    <div align='center'>
        <img src='./readme_images/launch page/pad_map.jpg' width='200'>
    </div>

This is the full 1st container:

<div align='center'>
    <img src='./readme_images/launch page/launch_page_1_dark.jpg' width='200'>
    <img src='./readme_images/launch page/launch_page_1_light.jpg' width='200'>
</div>


- The second container contains the data of the governament agency or private company which hosts the launch:
    - an image with the logo of the agency;
    - the name of the agency;
    - the pourpose of the launch or the type of agency, with the relative country flag obtained with the  [Rest Countries](https://restcountries.com) api;
    - the head of the agency;
    - the description of the agency.

This is the full 2nd container:

<div align='center'>
    <img src='./readme_images/launch page/launch_page_2_dark.jpg' width='200'>
    <img src='./readme_images/launch page/launch_page_2_light.jpg' width='200'>
</div>

- The third container contains the rocket configuration data:
    - the image of the rocket (if it is different from the one of the launch, otherwise it's not displayed);
    - the name of the rocket;
    - the full name of the rocket (if it's different from the name of the rocket, otherwise it's not displayed);
    - a detail section (the values are ``'---'`` if not present in the json) which contains:
        - the height of the rocket in m;
        - the maximum number of stages the rocket can have;
        - the total thrust during the liftoff in kN;
        - the mass of the rocket during the liftoff in tonnes;
        - the playload mass that the rocket is able to carry into the Low Earth Orbit, from 200 up to 2,000 km
        - the playload mass that the rocket is able to carry into the Geostationary Transfer Orbit (35,786 km);
        - the number of successful launches;
        - the number of failed launches;

        By clicking on the detail is possible to show a ``SnackBar`` providing the full description:
        <div align='center'>
            <img src='./readme_images/launch page/launch_page_detail_dark.jpg' width='200'>
            <img src='./readme_images/launch page/launch_page_detail_light.jpg' width='200'>
        </div>

    - the description of the rocket.

This is the full 3th container:

<div align='center'>
    <img src='./readme_images/launch page/launch_page_3_dark.jpg' width='200'>
    <img src='./readme_images/launch page/launch_page_3_light.jpg' width='200'>
</div>

## TODO
- [x] Separate ``LaunchStatus`` widget in 2 different widget, one for the big and one for the smaller version (+ modified doc and added missing);
- [x] Improve custom AppBar code in app_bar.dart (make it a proper widget);
- [x] Configure ``Updater`` to support links;
- [x] Fix bug in_readJsonField that reads a null value and returns 'null' as a String;
- [x] ~~Correct text error in api at convertGibberish~~ Method removed;
- [x] Round drop-down menu corners;
- [x] Convert json in order not to have fucked up text;
- [x] Stop showing empty launch descrictions which only contain '?' (like almost every fk chinese rocket).
