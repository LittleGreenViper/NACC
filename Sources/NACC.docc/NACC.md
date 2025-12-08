# ``NACC``

![The Project Icon](icon.png)

## Overview

This is a simple "cleantime calculator" app, for NA members (It is not associated with [Narcotics Anonymous World Services](https://na.org), or NA, as a whole. It is simply a tool, written for NA members, by NA members).

## Get The App

### Get the application, itself

|The app is available for free, from the iOS/iPadOS/MacOS Apple App Store|
|:--:|
|[![Apple App Store Badge](Download_on_the_App_Store_Badge_US-UK_RGB_blk_092917.svg)](https://apps.apple.com/us/app/nacc/id452299196)|

### Get the source code

|The Source Is Available, As [MIT-licensed](https://opensource.org/licenses/MIT) Open-Source Code, on GitHub|
|:--:|
|[![Octocat](Octocat.png)](https://github.com/LittleGreenViper/NACC)|

### Read All About It

- [Complete Technical Documentation is Available on GitHub](https://littlegreenviper.github.io/NACC/)

- [Complete User Documentation is Available on the Little Green Viper Software Development LLC Web Site](https://littlegreenviper.com/portfolio/nacc/)

## Basic Operation

### The Initial ("My Cleantime") Screen

The initial screen that you see, upon starting the app, has a basic "cleantime report" text button. If you select it, a date picker will appear, allowing you to enter a cleandate. Once you have entered a date, the report updates to reflect the new cleandate.

|Figure 1: The Initial Screen|Figure 2: Dark Mode|
|:----:|:----:|
|![Figure 1](Image01.png)|![Figure 2](Image02.png)|

#### Setting A Cleandate

|Figure 3: The Date Picker|Figure 4: Dark Mode|
|:----:|:----:|
|![Figure 3](Image03.png)|![Figure 4](Image04.png)|

> NOTE: On some screens, or if the device is rotated, the date picker may show up as "wheels."

|Figure 5: The Picker As "Wheels"|
|:----:|:----:|
|![Figure 5](Image05.png)|

The app remembers the last date entered.

|Figure 6: After Changing the Date|Figure 7: Dark Mode|
|:----:|:----:|
|![Figure 6](Image06.png)|![Figure 7](Image07.png)|

#### Sharing Your Cleandate

Selecting the "action" button (upper left of the Initial Screen) will allow you to share the report with others, using different apps, like [Messages](https://apps.apple.com/us/app/messages/id1146560473), or [Mail](https://apps.apple.com/us/app/mail/id1108187098), or print out the report.

Upon first selecting the button, you will be presented with an alert, asking you to select what you wish to do.

|Figure 8: The Action Selection Alert|Figure 9: Dark Mode|
|:----:|:----:|
|![Figure 8](Image08.png)|![Figure 9](Image09.png)|

##### Sharing Your Cleantime

If you select "Share My Cleantime," you will be presented with a classic Share Sheet.

|Figure 10: The Share Sheet|Figure 11: Dark Mode|
|:----:|:----:|
|![Figure 10](Image10.png)|![Figure 12](Image11.png)|

This will include [a Universal Link](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app) to the report. This link will either take you to a Web page, showing keytags, or will open the app, setting the date.

[Here is an example _(`https://nacc.littlegreenviper.com/?2010-03-17`)_](https://nacc.littlegreenviper.com/?2010-03-17)

If you have the app, it will open the app, and set the date to March 17, 2010. If you do not have the app, it will take you to a Web page, showing a keytag strip, denoting the cleantime, and with links to [the app in the App Store](https://littlegreenviper.com/portfolio/nacc/).

##### Printing the Report

If you select "Print My Cleantime," you will be presented with a Print Screen.

|Figure 12: The Print Screen|Figure 13: Dark Mode|
|:----:|:----:|
|![Figure 12](Image12.png)|![Figure 13](Image13.png)|


|Figure 14: The Print Preview|
|:----:|:----:|
|![Figure 14](Image14.png)|

#### Setting a Calendar Event

Selecting the "calendar" button (just to the right of the Action Button) will allow you to create calendar reminders, every year, starting from the cleandate.

It will "pre-populate" an event, with the date as an "all day" starting date, and yearly repeats.

|Figure 15: The Calendar Entry Screen|Figure 16: Dark Mode|
|:----:|:----:|
|![Figure 15](Image15.png)|![Figure 16](Image16.png)|

### The App Information Screen

Selecting the "Info" button (upper right of the Initial Screen) will bring in a screen, displaying information about the app.

|Figure 17: App Information Screen|Figure 18: Dark Mode|
|:----:|:----:|
|![Figure 17](Image17.png)|![Figure 18](Image18.png)|

The three buttons along the bottom will take you to the app settings panel, in the device's Settings app, the Web site Privacy Policy Page (in Safari), and the main Little Green Viper Software Development LLC Web site, respectively.

### The Cleantime Commemoration Tab Screen

If you select the cleantime report, it will bring in another screen, that will have three tabs. These tabs will display the cleantime, using keytags or medallions.

If you have entered a date less than 1 year in the past, then the Medallions tab is not available.

|Figure 19: Keytag Array Tab|Figure 20: Dark Mode|
|:----:|:----:|
|![Figure 19](Image19.png)|![Figure 20](Image20.png)|

|Figure 21: Keytag Strip Tab|Figure 22: Dark Mode|
|:----:|:----:|
|![Figure 21](Image21.png)|![Figure 22](Image22.png)|

|Figure 23: Medallion Array Tab|Figure 24: Dark Mode|
|:----:|:----:|
|![Figure 23](Image23.png)|![Figure 24](Image24.png)|

Selecting the logo (above the report) will take you to the Keytag Array Tab.

Selecting the keytag/medallion (under the report) will take you to the results as either medallions, or as the array of keytags.

If you select the action button, you will now be able to print the display, share it (and the report), via [Messages](https://apps.apple.com/us/app/messages/id1146560473), or [Mail](https://apps.apple.com/us/app/mail/id1108187098), or save the image into your Photo Library.

## URL Scheme

The app can be opened from other apps (like [Safari](https://apps.apple.com/us/app/safari/id1146562112) or [Mail](https://apps.apple.com/us/app/mail/id1108187098)), using a special URL scheme.

The URL scheme is thus:

**`nacc://`**_[?YYYY-MM-DD[/N]]_

The Universal Link Scheme is:

**`https://nacc.littlegreenviper.com/`**_[?YYYY-MM-DD[/N]]_

_YYYY-MM-DD_ is a standard [ISO 8601 calendar date](https://en.wikipedia.org/wiki/ISO_8601#Calendar_dates) (For example, September first, 1980, is 1980-09-01).

The earliest date is October 5, 1953 (1953-10-05)

_N_ is the numerical index of a tab:

- 0 is Keytag Array
- 1 is Keytag Strip
- 2 is Medallions

|Figure 25: URL Entry In Safari|Figure 26: Permission Alert|
|:----:|:----:|
|![Figure 25](Image25.png)|![Figure 26](Image26.png)|

### Example URL Scheme URLs

(Will only work on a device with NACC installed)

- [`nacc://`](nacc://)
  This opens the app, but does nothing else.

- [`nacc://?1980-09-01`](nacc://?1980-09-01)
  This opens the app, and sets the cleantime to September 1st, 1980. It will set to the main screen.

- [`nacc://?2020-03-17/0`](nacc://?2020-03-17/0)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Keytag Array tab.

- [`nacc://?2020-03-17/1`](nacc://?2020-03-17/1)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Vertical Keytag Strip tab.

- [`nacc://?2020-03-17/2`](nacc://?2020-03-17/2)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Medallions tab.

### Example Universal Link URLs

_Will work on any device, but will open the NACC, if it is installed. If not, a simple Web page with the date will be shown, along with instructions for accessing the app on the App Store_

- [`https://nacc.littlegreenviper.com`](https://nacc.littlegreenviper.com)
  This opens the app, but does nothing else.

- [`https://nacc.littlegreenviper.com/?1980-09-01`](https://nacc.littlegreenviper.com/?1980-09-01)
  This opens the app, and sets the cleantime to September 1st, 1980. It will set to the main screen.

- [`https://nacc.littlegreenviper.com/?2020-03-17/0`](https://nacc.littlegreenviper.com/?2020-03-17/0)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Keytag Array tab.

- [`https://nacc.littlegreenviper.com/?2020-03-17/1`](https://nacc.littlegreenviper.com/?2020-03-17/1)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Vertical Keytag Strip tab.

- [`https://nacc.littlegreenviper.com/?2020-03-17/2`](https://nacc.littlegreenviper.com/?2020-03-17/2)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Medallions tab.

## Widgets

As of version 5.4, you can now add widgets to your iPhone, iPad, or Mac screens.

## Watch App

As of version 6.0, there is now a companion Watch app, with complications.

> NOTE: In order to set the date on the Watch app, double-tap in the app screen.

## Dependencies

The app is dependent upon the following 4 [Great Rift Valley Software Company](https://riftvalleysoftware.com) SPM modules:

- [RVS_GeneralObserver](https://github.com/RiftValleySoftware/RVS_GeneralObserver)
- [RVS_Generic_Swift_Toolbox](https://github.com/RiftValleySoftware/RVS_Generic_Swift_Toolbox)
- [RVS_PersistentPrefs](https://github.com/RiftValleySoftware/RVS_PersistentPrefs)
- [RVS_UIKit_Toolbox](https://github.com/RiftValleySoftware/RVS_UIKit_Toolbox)

It is also dependent upon the following 2 [Little Green Viper Software Development LLC](https://littlegreenviper.com) SPM modules:

- [LGV_Cleantime](https://github.com/LittleGreenViper/LGV_Cleantime)
- [LGV_UICleantime](https://github.com/LittleGreenViper/LGV_UICleantime)

## License And Copyright

The code and keytag images are [MIT license](https://opensource.org/licenses/MIT). Use them as you will.

However, the medallion images are renderings of the standard bronze [NA World Services](https://na.org) (NAWS, Inc.) [cleantime commemoration medallions](https://cart-us.na.org/2-keytags-medallions/medallions-bronze/bronze-medallions-bronze). The design of those medallions is copyrighted by NA World Services.

It is important to treat the intellectual property of NA with respect.


