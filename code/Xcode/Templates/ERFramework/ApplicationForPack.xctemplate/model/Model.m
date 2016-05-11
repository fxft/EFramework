//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//


#import "___VARIABLE_classPrefix:identifier___Model.h"

@implementation NSString (ModelMock)

- (id)valueForUndefinedKey:(NSString *)key{
    
    if ([self rangeOfString:[HMWebAPI methodMock]].location!=NSNotFound) {
        id respondObject = nil;
        /*
         //Message = "<null>";
         //Result =     {
         //    Message = "\U767b\U5f55\U6210\U529f";
         //    State = 3;
         //};
         //SessionState = 1;
         //Success = 1;
         */
        if ([self isEqualToString:[HMWebAPI methodMock]]||[self isEqualToString:[HMWebAPI methodMockSuccess]]) {
            id result = @{@"Message":@"",@"State":@(1)};
            if ([key isEqualToString:@"FindInsuranceCompanys"]){
                
            }
            respondObject = @{@"Message": @"",@"SessionState":@(1),@"Success":@(1),@"Result":result};
        }else if ([self isEqualToString:[HMWebAPI methodMockFail]]) {
            id result = @{@"Message":@"",@"State":@(1)};
            if ([key isEqualToString:@"FindInsuranceCompanys"]){
                
            }
            respondObject = @{@"Message": @"",@"SessionState":@(1),@"Success":@(1),@"Result":result};
        }else if ([self isEqualToString:[HMWebAPI methodMockTimeOut]]) {
            id result = @{@"Message":@"",@"State":@(1)};
            if ([key isEqualToString:@"FindInsuranceCompanys"]){
                
            }
            respondObject = @{@"Message": @"",@"SessionState":@(1),@"Success":@(1),@"Result":result};
        }
        
        return respondObject;
    }else{
        return [super valueForUndefinedKey:key];
    }
}

@end


#pragma mark -

@implementation ___VARIABLE_classPrefix:identifier___Model
DEF_SINGLETON(___VARIABLE_classPrefix:identifier___Model)


- (void)dealloc
{
    
    HM_SUPER_DEALLOC();
}
@end


@implementation WebAPIResult{
    id            _resultObject;
    Class         _resultClass;
}

@synthesize Message;
@synthesize SessionState;
@synthesize Success;
@synthesize Result=_Result;
@synthesize resultClass=_resultClass;
@synthesize resultObject = _resultObject;
@synthesize successI;
@synthesize sessionStateI;

- (void)setResult:(NSObject *)Result{
//    [_Result release];
    _Result = nil;
    if (![Result isKindOfClass:[NSNull class]]) {
        _Result = [Result retain];
    }
}

- (void)setResultClass:(Class)resultClass{
    if (self.Result) {
        
        if ([self.Result isKindOfClass:[NSDictionary class]]) {
            self.resultObject = [(NSDictionary*)self.Result objectForClass:resultClass];
        }else if ([self.Result isKindOfClass:[NSArray class]]){
            self.resultObject = [resultClass objectsFromArray:self.Result];
        }else if ([self.Result isKindOfClass:[NSNull class]]){
            self.resultObject = nil;
        }else{
            self.resultObject = self.Result;
        }
    }
}

- (NSInteger)successI{
    return [self.Success integerValue];
}

- (NSInteger)sessionStateI{
    return [self.SessionState integerValue];
}

- (void)dealloc
{
    self.Message = nil;
    self.Result = nil;
    self.Success = nil;
    self.SessionState = nil;
    self.resultObject = nil;
    HM_SUPER_DEALLOC();
}

@end

#pragma mark -

@implementation ResultObject
@synthesize Message;
@synthesize State;


- (NSInteger)stateI{
    return [self.State integerValue];
}

- (void)dealloc
{

    self.Message = nil;
    
    HM_SUPER_DEALLOC();
}


@end


