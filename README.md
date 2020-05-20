# <center>Alderis</center>
**<center>Try it yourself: `pod try Alderis`</center>**

Alderis is a fresh new color picker, with a gentle, fun, and dead simple user interface. It aims to incorporate the usual elements of a color picker, in a way that users will find easy and fun to use.

The user can start by selecting a color they like on the initial color palette tab, and either accept it, or refine it using the color wheel and adjustment sliders found on the two other tabs.

Alderis is named for the Alderamin (Alpha) star in the Cepheus (Cephei) constellation. It’s a friend of [Cephei](https://hbang.github.io/libcephei/), although it doesn’t depend on or otherwise require the developer to use Cephei.

## Screenshots
[<img src="screenshots/alderis-1.jpg" width="180" height="390">](screenshots/alderis-1.jpg)
&nbsp;
[<img src="screenshots/alderis-2.jpg" width="180" height="390">](screenshots/alderis-2.jpg)
&nbsp;
[<img src="screenshots/alderis-3.jpg" width="180" height="390">](screenshots/alderis-3.jpg)
&nbsp;
[<img src="screenshots/alderis-4.jpg" width="180" height="390">](screenshots/alderis-4.jpg)

## libcolorpicker Compatibility
Alderis acts as a drop-in replacement for [libcolorpicker](https://github.com/atomikpanda/libcolorpicker), an abandoned but still very popular color picker library on jailbroken iOS. Packages can simply change their dependencies list to replace `org.thebigboss.libcolorpicker` with `ws.hbang.alderis` to switch their color picker to Alderis. No other changes required!

As libcolorpicker is known to no longer work on iOS 13.4, we now recommend switching to Alderis as soon as possible.

Alderis also provides a replacement, cleaner interface for preference bundles. Example usage:

```xml
<dict>
	<key>cell</key>
	<string>PSLinkCell</string>
	<key>cellClass</key>
	<string>HBColorPickerTableCell</string>
	<key>defaults</key>
	<string>com.example.myawesomething</string>
	<key>default</key>
	<string>#33b5e5</string>
	<key>label</key>
	<string>Tint Color</string>
	<key>showAlphaSlider</key>
	<true/>
	<key>PostNotification</key>
	<string>com.example.myawesomething/ReloadPrefs</string>
</dict>
```

Compared to libcolorpicker’s API design, this leans on the fundamentals of Preferences.framework, including using the framework’s built-in preference value getters/setters system. In fact, the only two distinct parts are the `cellClass` and the `showAlphaSlider` key. The rest should seem pretty natural!

The functionality described in this section is only available in the jailbreak package for Alderis, specifically in the `libcolorpicker.dylib` binary ([lcpshim](https://github.com/hbang/Alderis/tree/master/lcpshim)), and is not included in the App Store (CocoaPods/Carthage) version.

## License
Licensed under the Apache License, version 2.0. Refer to [LICENSE.md](https://github.com/hbang/Alderis/blob/master/LICENSE.md).
