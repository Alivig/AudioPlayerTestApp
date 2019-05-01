//
//  IATDownloadableImageView.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/24/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATRoundedImageView.h"

IB_DESIGNABLE
@interface IATDownloadableImageView : IATRoundedImageView

- (void)setDownloadableImage:(NSString*)urlString;
- (void)setDownloadableImage:(NSString*)urlString withCallback:(IATSuccessCallbackType)callback;

@end
