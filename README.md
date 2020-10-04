# ![Alderis Color Picker](screenshots/logo.jpg)

**<center>Try it yourself: `pod try Alderis`</center>**

Alderis is a fresh new color picker, with a gentle, fun, and dead simple user interface. It aims to incorporate the usual elements of a color picker, in a way that users will find easy and fun to use.

The user can start by selecting a color they like on the initial color palette tab, and either accept it, or refine it using the color wheel and adjustment sliders found on the two other tabs.

Alderis is named for the Alderamin (Alpha) star in the Cepheus (Cephei) constellation. (There is no dependency on the [Cephei](https://hbang.github.io/libcephei/) project.)

**[Documentation](https://hbang.github.io/Alderis/)**

## Screenshots

<table align="center">
<tr>
<td><a href="screenshots/alderis-1.jpg"><img src="screenshots/alderis-1.jpg" width="180"></a></td>
<td><a href="screenshots/alderis-2.jpg"><img src="screenshots/alderis-2.jpg" width="180"></a></td>
</tr>
<tr>
<td><a href="screenshots/alderis-3.jpg"><img src="screenshots/alderis-3.jpg" width="180"></a></td>
<td><a href="screenshots/alderis-4.jpg"><img src="screenshots/alderis-4.jpg" width="180"></a></td>
</tr>
</table>

## Installation

### CocoaPods
Add to your Podfile:

```ruby
pod 'Alderis', '~> 1.1'
```

And then run `pod install`.

### Carthage
Add to your Cartfile:

```ruby
github 'hbang/Alderis' ~> 1.1
```

And then run `carthage update`.

### Swift Package Manager
Not yet available due to [#13](https://github.com/hbang/Alderis/issues/13).

### Jailbreak packages
Add `ws.hbang.alderis (>= 1.1)` to your `Depends:` list.

## Preference Bundles and libcolorpicker Compatibility
Alderis acts as a drop-in replacement for [libcolorpicker](https://github.com/atomikpanda/libcolorpicker), an abandoned but still very popular color picker library on jailbroken iOS. Packages can simply change their dependencies list to replace `org.thebigboss.libcolorpicker` with `ws.hbang.alderis` to switch their color picker to Alderis. No other changes required!

For more information, refer to [the docs](https://hbang.github.io/Alderis/preference-bundles.html).

## License
Licensed under the Apache License, version 2.0. Refer to [LICENSE.md](https://github.com/hbang/Alderis/blob/master/LICENSE.md).

Header backdrop photo credit: [John-Mark Smith](https://unsplash.com/@mrrrk_smith) on Unsplash
