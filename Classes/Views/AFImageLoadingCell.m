//
//  AFImageLoadingCell.m
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import "AFImageLoadingCell.h"
#import "EGOImageView.h"


@implementation AFImageLoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"placeholder.png"]];
		imageView.frame = CGRectMake(5.0f, 5.0f, 50.0f, 50.0f);
		[self.contentView addSubview:imageView];
	}
	
    return self;
}

- (void)setImageURL:(NSURL *)url {
	imageView.imageURL = url;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	
	if(!newSuperview) {
		[imageView cancelImageLoad];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.textLabel.frame = CGRectOffset(self.textLabel.frame, 60.0f, 0.0f);
	self.detailTextLabel.frame = CGRectOffset(self.detailTextLabel.frame, 60.0f, 0.0f);
}

- (void)dealloc {
	[imageView release];
    [super dealloc];
}

@end
