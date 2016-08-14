//
//  color.m
//  EFExtend
//
//  Created by mac on 15/3/12.
//  Copyright (c) 2015年 Eric. All rights reserved.
//

#import "color.h"


@interface color ()
@property (nonatomic,strong) NSMutableDictionary *all;
@end

@implementation color
@synthesize all;

- (void)dealloc
{
    self.all = nil;
    HM_SUPER_DEALLOC();
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.customNavLeftBtn setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [self.customNavLeftBtn setFrame:CGRectMakeBound(32, 32)];
    
    [self.customNavRightBtn setTitle:@"获取" forState:UIControlStateNormal];
    [self.customNavRightBtn sizeToFit];
    
    [self performSelector:@selector(readColorXml) withObject:nil];
    
    /*
     颜色工具类
     #import "UIColor+HMExtension.h"
     取色器
     #import "UIColor+FlatColors.h"
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

ON_Button(signal){
    UIButten *btn = signal.source;
    if ([signal is:[UIButten TOUCH_UP_INSIDE]]) {
        if ([btn is:@"leftBtn"]) {
            [self backWithAnimate:YES];
        }else if ([btn is:@"rightBtn"]){
//            [self performSelector:@selector(readColorXml) withObject:nil];
        }
    }
}

- (void)readColorXml{
    [self showLoaddingTip:@"正在获取" timeOut:20.f];
    NSString *colorxml = [NSString stringWithContentsOfFile:[HMSandbox pathWithbundleName:nil fileName:@"material_colors.xml"] encoding:NSUTF8StringEncoding error:nil];
    NSError *error = nil;
    
    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithString:colorxml encoding:NSUTF8StringEncoding error:&error];
    
    self.all = [NSMutableDictionary dictionary];
    
    for (ONOXMLElement *element in document.rootElement.children) {
        
//        INFO(@"%@: %@ %@", element.tag, element.attributes);
        if ([element.tag isEqualToString:@"color"]) {
            
            NSString *name = [element valueForAttribute:@"name"];
            NSArray *comp = [name componentsSeparatedByString:@"_"];
            NSString *key = [comp safeObjectAtIndex:1];
            NSMutableArray *items = [all objectForKey:key];
            if (items==nil) {
                items = [NSMutableArray array];
                [all setObject:items forKey:key];
            }
            [items addObject:@{name:element.stringValue}];
//            printf("\n+ (UIColor *)%s;\n",[name UTF8String]);
//            printf("\n+ (UIColor *)%s{\n\
//                 return [UIColor fromHexValue:0x%s];\n\
//                 }\n",[name UTF8String],[[element.stringValue substringFromIndex:1] UTF8String]);
            
        }
    }
    [self.tableView reloadData];
    self.tableView.sectionIndexColor = [UIColor blackColor];
//
//    colorxml = [NSString stringWithContentsOfFile:[HMSandbox pathWithbundleName:nil fileName:@"baidu.html"] encoding:NSUTF8StringEncoding error:nil];
//    
//    document = [ONOXMLDocument HTMLDocumentWithString:colorxml encoding:NSUTF8StringEncoding error:&error];
//    for (ONOXMLElement *element in document.rootElement.children) {
//        
//        INFO(@"%@: %@ %@", element.tag, element.attributes);
//        
//    }
//    // Support for Namespaces
//    NSString *author = [[document.rootElement firstChildWithTag:@"body" inNamespace:@"dc"] stringValue];
//    
//    // Automatic Conversion for Number & Date Values
//    NSDate *date = [[document.rootElement firstChildWithTag:@"created_at"] dateValue]; // ISO 8601 Timestamp
//    NSInteger numberOfWords = [[[document.rootElement firstChildWithTag:@"word_count"] numberValue] integerValue];
//    BOOL isPublished = [[[document.rootElement firstChildWithTag:@"is_published"] numberValue] boolValue];
//    
//    // Convenient Accessors for Attributes
//    NSString *unit = [document.rootElement firstChildWithTag:@"Length"][@"unit"];
//    NSDictionary *authorAttributes = [[document.rootElement firstChildWithTag:@"author"] attributes];
//    
//    // Support for XPath & CSS Queries
//    [document enumerateElementsWithXPath:@"//Content" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
//        NSLog(@"%@", element);
//    }];
    [self tipsDismissNoAnimated];
}


#pragma  mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *key = [self.all.allKeys safeObjectAtIndex:section];
    return [[self.all objectForKey:key] count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.all.allKeys.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.all.allKeys safeObjectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"listCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    NSDictionary *dic = [[self.all objectForKey:[self.all.allKeys safeObjectAtIndex:indexPath.section]] safeObjectAtIndex:indexPath.row];
    NSString *color = dic.allValues.firstObject;
    NSString *name = dic.allKeys.firstObject;
    cell.textLabel.text = [NSString stringWithFormat:@"[UIColor %@]",name];
    cell.detailTextLabel.text = color;
    cell.textLabel.textColor = RGB(0, 0, 0);
    cell.backgroundColor = [UIColor colorWithString:color];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.textLabel.style__ = [HMUIShapeStyle styleWithShape:[HMUIRoundedRectangleShape shapeWithTopLeft:0 topRight:10 bottomRight:10 bottomLeft:0] next:[HMUIInsetStyle styleWithInset:UIEdgeInsetsAll(10) next:[HMUISolidFillStyle styleWithColor:[[UIColor md_amber_100] colorWithAlphaComponent:.9] next:nil]]];;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [[self.all objectForKey:[self.all.allKeys safeObjectAtIndex:indexPath.section]] safeObjectAtIndex:indexPath.row];
    NSString *color = dic.allValues.firstObject;

    [HMUINavigationBar setBackgroundColor:[UIColor colorWithString:color]];

}
@end
