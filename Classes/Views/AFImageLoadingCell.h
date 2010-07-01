//
//  AFImageLoadingCell.h
//  Gowalla-Basic
//
//  Created by Mattt Thompson on 10/06/29.
//  Copyright 2010 Mattt Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;

@interface AFImageLoadingCell : UITableViewCell {
@private
	EGOImageView* imageView;
}

- (void)setImageURL:(NSURL *)url;

@end
