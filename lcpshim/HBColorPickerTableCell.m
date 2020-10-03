@import Alderis;
#import "libcolorpicker.h"
#import <Preferences/PSSpecifier.h>

@interface UIView ()
- (UIViewController *)_viewControllerForAncestor;
@end

@interface HBColorPickerTableCell () <HBColorPickerDelegate>
@end

@implementation HBColorPickerTableCell {
	HBColorWell *_colorWell;
	HBColorPickerViewController *_viewController;
}

#pragma mark - PSTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		_colorWell = [[HBColorWell alloc] initWithFrame:CGRectZero];
		self.accessoryView = _colorWell;
	}
	return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
	[super refreshCellContentsWithSpecifier:specifier];
	self.cellTarget = self;
	self.cellAction = @selector(_present);
	[self _updateValue];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	UIColor *color = _colorWell.color;
	[super setHighlighted:highlighted animated:animated];
	// stop deleting my background color Apple!!!
	_colorWell.color = color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (selected) {
		[self _present];
	}
}

#pragma mark - Properties

- (NSString *)_hbcp_defaults {
	return self.specifier.properties[@"defaults"];
}

- (NSString *)_hbcp_key {
	return self.specifier.properties[@"key"];
}

- (BOOL)_hbcp_supportsAlpha {
	return self.specifier.properties[@"supportsAlpha"] ? ((NSNumber *)self.specifier.properties[@"supportsAlpha"]).boolValue : NO;
}

#pragma mark - Getters/setters

- (UIColor *)_colorValue {
	return LCPParseColorString([self.specifier performGetter], nil) ?: [UIColor colorWithWhite:0.6 alpha:1];
}

- (void)_setColorValue:(UIColor *)color {
	[self.specifier performSetterWithValue:color.hbcp_propertyListValue];
	[self _updateValue];
}

- (void)_updateValue {
	_colorWell.color = self._colorValue;
}

#pragma mark - Present

- (void)_present {
	_viewController = [[HBColorPickerViewController alloc] init];
	_viewController.delegate = self;
	_viewController.popoverPresentationController.sourceView = self;

	UIColor *color = self._colorValue ?: [UIColor colorWithWhite:0.6 alpha:1];
	HBColorPickerConfiguration *configuration = [[HBColorPickerConfiguration alloc] initWithColor:color];
	configuration.title = self.specifier.properties[@"label"];
	configuration.supportsAlpha = self._hbcp_supportsAlpha;
	_viewController.configuration = configuration;

	UIViewController *rootViewController = self._viewControllerForAncestor ?: [UIApplication sharedApplication].keyWindow.rootViewController;
	[rootViewController presentViewController:_viewController animated:YES completion:nil];
}

#pragma mark - HBColorPickerDelegate

- (void)colorPicker:(HBColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
	[self _setColorValue:color];
}

@end
