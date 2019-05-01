//
//  IATArtistsView.h
//  TestApp
//
//  Created by Ivan Alekseev on 4/30/19.
//  Copyright © 2019 IA. All rights reserved.
//

#import "IATRoundedView.h"

@class IATArtist;

IB_DESIGNABLE
@interface IATArtistsView : IATRoundedView

- (void)updateWithArtists:(NSOrderedSet <IATArtist*>*)artists;

@end
