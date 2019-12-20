#include "BSTMRootListController.h"
#import <spawn.h>


@implementation BSTMRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}


@end
