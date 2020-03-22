@import Alderis;
#import "libcolorpicker.h"
#import <Preferences/PSSpecifier.h>

@interface UIView ()
- (UIViewController *)_viewControllerForAncestor;
@end

@interface HBColorPickerTableCell () <HBColorPickerDelegate>
@end

@implementation HBColorPickerTableCell {
	HBColorPickerCircleView *_circleView;
	HBColorPickerViewController *_viewController;
}

#pragma mark - PSTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	if (self) {
		_circleView = [[HBColorPickerCircleView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		self.accessoryView = _circleView;
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
	UIColor *backgroundColor = _circleView.backgroundColor;
	[super setHighlighted:highlighted animated:animated];
	// stop deleting my background color Apple!!!
	_circleView.backgroundColor = backgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (selected) {
		[self _present];
	} else {
		[super setSelected:selected animated:animated];
	}
}

#pragma mark - Properties

- (NSString *)_hbcp_defaults {
	return self.specifier.properties[@"defaults"];
}

- (NSString *)_hbcp_key {
	return self.specifier.properties[@"key"];
}

- (BOOL)_hbcp_showAlpha {
	return self.specifier.properties[@"libcolorpicker"][@"alpha"] ? ((NSNumber *)self.specifier.properties[@"libcolorpicker"][@"alpha"]).boolValue : NO;
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
	_circleView.backgroundColor = self._colorValue;
}

#pragma mark - Present

- (void)_present {
	_viewController = [[HBColorPickerViewController alloc] init];
	_viewController.delegate = self;
	_viewController.color = self._colorValue ?: [UIColor colorWithWhite:0.6 alpha:1];

	UIViewController *rootViewController = self._viewControllerForAncestor ?: [UIApplication sharedApplication].keyWindow.rootViewController;
	[rootViewController presentViewController:_viewController animated:YES completion:nil];
}

#pragma mark - HBColorPickerDelegate

- (void)colorPicker:(HBColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color {
	[self _setColorValue:color];
}

@end
