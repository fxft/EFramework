//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import <Foundation/Foundation.h>

@interface NSString (ModelMock)

@end

@interface ___VARIABLE_classPrefix:identifier___Model : NSObject
AS_SINGLETON(___VARIABLE_classPrefix:identifier___Model)


@end


@interface WebAPIResult : NSObject
//Message = "<null>";
//Result =     {
//    Message = "\U767b\U5f55\U6210\U529f";
//    State = 3;
//};
//SessionState = 1;
//Success = 1;
@property (nonatomic, copy)  NSString *      Message;
@property (nonatomic, HM_STRONG)  NSNumber *     Success;
@property (nonatomic, HM_STRONG)  NSNumber *     SessionState;
@property (nonatomic, HM_STRONG)  NSObject * Result;

@property (nonatomic, assign) Class         resultClass;
@property (nonatomic, HM_STRONG) id         resultObject;
@property (nonatomic, assign, readonly)  NSInteger     successI;
@property (nonatomic, assign, readonly)  NSInteger     sessionStateI;

@end


@interface ResultObject : NSObject

@property (nonatomic,copy)  NSString *      Message;
@property (nonatomic,HM_STRONG)  NSNumber *     State;
@property (nonatomic, assign, readonly)  NSInteger     stateI;

@end