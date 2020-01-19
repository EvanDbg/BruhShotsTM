//
// TR1TableCell.m
// 
// This code is directly from HBTintedTableCell in Cephei and taken from Kritanta :))
// Don't fix what ain't broke
//

#import "TR1TableCell.h"

@implementation TR1TableCell

- (void)tintColorDidChange {
	[super tintColorDidChange];
	self.textLabel.textColor = self.tintColor;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
	[super refreshCellContentsWithSpecifier:specifier];

	if ([self respondsToSelector:@selector(tintColor)]) {
		self.textLabel.textColor = self.tintColor;
	}
}

@end