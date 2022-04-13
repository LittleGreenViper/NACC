# ``NACC (NA Cleantime Calculator)``

![The Project Icon](icon.png)

## Overview

This is a simple "cleantime calculator" app, for NA members (It is not associated with [Narcotics Anonymous World Services](https://na.org), or NA, as a whole. It is simply a tool, written for NA members, by NA members).

## Basic Operation

### The Initial ("My Cleantime") Screen

The initial screen that you see, upon starting the app, has a basic "wheel-style" date entry that allows you to enter a cleandate. Once you have entered a date, the label below the date entry changes into a report of the cleantime, and also becomes a "selectable" button.

|Figure 1: The Initial Screen|Figure 2: After Changing the Date|
|:----:|:----:|
|![Figure 1](img/Figure-01.png)|![Figure 2](img/Figure-02.png)|

The app will change to accomodate Dark Mode (Figure 2):

|Figure 3: Dark Mode|
|:----:|
|![Figure 3](img/Figure-03.png)|

Tapping on the logo will take you to [the Little Green Viper Software Development Web site](https://littlegreenviper.com),

Tapping on the "Info" button will bring in a screen, displaying information about the app.

Tapping on the "action" button will allow you to share the report with others, using different apps, like [Messages](https://apps.apple.com/us/app/messages/id1146560473), or [Mail](https://apps.apple.com/us/app/mail/id1108187098).

|Figure 4: Action Screen|
|:----:|
|![Figure 4](img/Figure-04.png)|

### The Cleantime Commemoration Tab Screen

If you select the cleantime report, it will bring in another screen, that will have three tabs. These tabs will display the cleantime, using keytags or medallions:

|Figure 5: Keytags in an Array|Figure 6: Keytags in a Vertical Strip|Figure 7: Medallions in an Array|
|:----:|:----:|:----:|
|![Figure 5](img/Figure-05.png)|![Figure 6](img/Figure-06.png)|![Figure 7](img/Figure-07.png)|

You can scroll these displays, and also do a pinch-to-zoom.

If you select the action button, you will now be able to print the display, share it (and the report), via [Messages](https://apps.apple.com/us/app/messages/id1146560473), or [Mail](https://apps.apple.com/us/app/mail/id1108187098), or save the image into your Photo Library.

|Figure 8: Action Screen|
|:----:|
|![Figure 8](img/Figure-08.png)|

The app remembers the last date entered, and the last tab selected. In some cases, tabs may not be enabled (If you have entered a date less than 30 days in the past, then only the Keytag Array tab is enabled. If less than 1 year, then the Medallions tab is disabled).

## URL Scheme

The app can be opened from other apps (like [Safari](https://apps.apple.com/us/app/safari/id1146562112) or [Mail](https://apps.apple.com/us/app/mail/id1108187098)), using a special URL scheme.

The URL scheme is thus:

**nacc://**_[YYYY-MM-DD[**/**N]]_

_YYYY-MM-DD_ is a standard [ISO 8601 calendar date](https://en.wikipedia.org/wiki/ISO_8601#Calendar_dates) (For example, September first, 1980, is 1980-09-01).

_N_ is the numerical index of a tab:

- 0 is Keytag Array
- 1 is Keytag Strip
- 2 is Medallions

### Example URLs (Will only work on an iOS device with NACC installed)

- [nacc://](nacc://)
  This opens the app, but does nothing else. You will be at the initial page, set to whatever the last date was.

- [nacc://1980-09-01](nacc://1980-09-01)
  This opens the app, and sets the cleantime to September 1st, 1980. It will open the commemoration tab screen, at whatever the last selected tab was.

- [nacc://2020-03-17/1](nacc://2020-03-17/1)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Vertical Keytag Strip tab.

- [nacc://2020-03-17/1](nacc://2020-03-17/1)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Vertical Keytag Strip tab.

- [nacc://2020-03-17/1](nacc://2020-03-17/2)
  This opens the app, and sets the cleantime to March 17th, 2020. It will open the commemoration tab screen, to the Medallions tab.
