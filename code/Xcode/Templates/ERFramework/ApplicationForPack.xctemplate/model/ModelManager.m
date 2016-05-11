//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___VARIABLE_classPrefix:identifier___ModelManager.h"

@implementation ___VARIABLE_classPrefix:identifier___ModelManager
DEF_SINGLETON(___VARIABLE_classPrefix:identifier___ModelManager)

DEF_NOTIFICATION(TEST)

- (BOOL)getLoginUpdate:(NSDictionary*)dic{
    
    NSString *command = @"/command";
    
//    NSDictionary *dic = @{@"phone":[CAUserCenter sharedInstance].userName,@"dt":[CAModel sharedInstance].loginUpdate.SettingTime==nil?@"0":[CAModel sharedInstance].loginUpdate.SettingTime};
    
    if (![self isSending:[HMWebAPI WebAPI] name:command]) {
        [[[self dealWith:[HMWebAPI WebAPI] timeout:20.f] input:[HMWebAPI params],dic,[HMWebAPI command],command,nil] send];
        return YES;
    }
    return NO;
}

ON_WebAPI(dlg){
    if (dlg.sending) {
        
        
//        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:MODELKEY_LOADING,MODELOBJECTKEY_STEP, nil];
//        [self postNotification:self.GSLOCATION withObject:dic];
        
    }else if (dlg.succeed){
        NSDictionary *params = [dlg.output objectForKey:[HMWebAPI params]];
        WebAPIResult *result = [params objectForClass:[WebAPIResult class]];
        if (result.successI) {
            if ([dlg isName:@"/command"]){
                result.resultClass = [ResultObject class];
                ResultObject *resultObject = result.resultObject;
                if (resultObject.stateI==1){
                    
                }
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:MODELKEY_SUCCEED,MODELOBJECTKEY_STEP,resultObject,MODELOBJECTKEY_OBJECT, nil];
                [self postNotification:self.TEST withObject:dic];
            }
            
        }else{
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:MODELKEY_FAILED,MODELOBJECTKEY_STEP, nil];
            if([dlg isName:@"/command"]){
                [self postNotification:self.TEST withObject:dic];
            }
        }
    }else if ((dlg.failed)||(dlg.cancelled)){
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:dlg.timeout?MODELKEY_TIMEOUT:MODELKEY_FAILED,MODELOBJECTKEY_STEP, nil];
        
        if([dlg isName:@"/command"]){
            
            [self postNotification:self.TEST withObject:dic];
        }
    }
#if (__ON__ == __HM_DEVELOPMENT__)
    CC( [self.class description],dlg.responseData?dlg.responseData:dlg.errorDesc);
#endif	// #if (__ON__ == __BEE_DEVELOPMENT__)
}

@end
