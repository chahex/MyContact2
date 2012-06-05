//
//  DetailViewController.h
//  MyContact2
//
//  Created by Xinkai HE on 6/3/12.
//  Copyright (c) 2012 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
