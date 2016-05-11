//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//


@interface TGSelectedCell : UITableViewCell

@property(nonatomic,strong) UIImageView *iconI;
@property(nonatomic,strong) UILabel *textL;

@end


@interface ThreeItem : NSObject
@property (nonatomic)  NSInteger indentationLevel;//缩进等级
@property (nonatomic)  BOOL end;//是否最后一层，是否为个体
@property (nonatomic)  BOOL selected;//该行是否已被选中
@property (nonatomic,HM_STRONG)  id data;//该行的数据体
@property (nonatomic)  NSUInteger rowNum;//该行在section中的索引
@end

@interface ___FILEBASENAMEASIDENTIFIER___ : HMUIBoard


//必须是包含对象ID，父ID，是否最终曾三个成员；eg.@{@"CARID":@"1",@"CARNO":@"测试企业1",@"DEPTID":@"1",@"DEPTNAME":@"测试企业",@"DATATYPE":@(0),@"UIMNO":@"111",@"ISONLINE":@"0"}
@property (nonatomic, HM_STRONG) NSMutableArray *sourceData;
@property (nonatomic) BOOL mutiSelect;
@property (nonatomic, HM_STRONG) NSObject *itemSelected;

AS_EVENT(DIDSELECTED)
AS_EVENT(MUTISELECTED)

@end
