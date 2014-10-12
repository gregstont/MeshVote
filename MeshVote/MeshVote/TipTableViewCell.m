//
//  TipTableViewCell.m
//  MeshVote
//
//  Created by Taylor Gregston on 10/11/14.
//  Copyright (c) 2014 Taylor Gregston. All rights reserved.
//

#import "TipTableViewCell.h"

@implementation TipTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _loaded = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
