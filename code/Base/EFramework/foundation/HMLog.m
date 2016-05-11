//
//  HMLog.m
//  CarAssistant
//
//  Created by Eric on 14-2-21.
//  Copyright (c) 2014年 Eric. All rights reserved.
//

#import "HMLog.h"

@interface HMLog ()
@property(nonatomic,HM_STRONG,readwrite)  NSMutableSet *showTags;

@end

@implementation HMLog{
    NSDateFormatter * dateFormatter;
    BOOL _enableTags;
    NSMutableSet * _showTags;
}
@synthesize enableTags = _enableTags;
@synthesize showTags = _showTags;
@synthesize showINFO = _showINFO;
@synthesize showPROGRESS = _showPROGRESS;
@synthesize showWARN = _showWARN;

static bool showTime = NO;

+ (HMLog *)sharedInstance
{
    static dispatch_once_t once;
    static HMLog * __singleton__;
    dispatch_once( &once, ^{ __singleton__ = [[[self class] alloc] init]; } );
    return __singleton__;
}


- (id)init
{
	self = [super init];
	if ( self )
	{
		dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
        
        [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
        
        _showTags = [NSMutableSet setWithObjects:@"INFO",@"WARN",@"PROGRESS",@"ERROR", nil];
	}
	return self;
}

- (void)dealloc
{
    
#if  __has_feature(objc_arc)
    
#else
    [dateFormatter release];
    [_showTags release];
#endif
	HM_SUPER_DEALLOC();
}

+(void)showTimeAhead:(BOOL)yesOrNo{
    showTime = yesOrNo;
}

+(void)setEnableTags:(BOOL)enable{
    [HMLog sharedInstance].enableTags = enable;
}

+(void)showINFO{
    [[HMLog sharedInstance]setShowINFO:YES];
}

+(void)hideINFO{
    [[HMLog sharedInstance]setShowINFO:NO];
}

-(void)setShowINFO:(BOOL)showINFO{
    _showINFO = showINFO;
   [self addOrDele:showINFO tag:@"INFO"];
}

+(void)showWARN{
    [[HMLog sharedInstance]setShowWARN:YES];
}

+(void)hideWARN{
     [[HMLog sharedInstance]setShowWARN:NO];
}

-(void)setShowWARN:(BOOL)showWARN{
    _showWARN = showWARN;
    [self addOrDele:showWARN tag:@"WARN"];
}

+(void)showPROGRESS{
    [[HMLog sharedInstance]setShowPROGRESS:YES];
}
+(void)hidePROGRESS{
    [[HMLog sharedInstance]setShowPROGRESS:YES];
}
-(void)setShowPROGRESS:(BOOL)showPROGRESS{
    _showPROGRESS = showPROGRESS;
    [self addOrDele:showPROGRESS tag:@"PROGRESS"];
}

+(void)showCustom:(NSString *)format, ...{
    va_list args;
    va_start( args, format );
    [[HMLog sharedInstance]showCustomWithFormat:format :args :YES];
    va_end(args);
}

+(void)showCustomAndSystem:(NSString *)format, ...{
    va_list args;
    va_start( args, format );
    [HMLog sharedInstance].showTags = [NSMutableSet setWithObjects:@"INFO",@"WARN",@"PROGRESS",@"ERROR", nil];
    [[HMLog sharedInstance]showCustomWithFormat:format :args :YES];
    va_end(args);
}

+(void)hideCustom:(NSString *)format, ...{
    va_list args;
    va_start( args, format );
    [[HMLog sharedInstance]showCustomWithFormat:format :args :NO];
    va_end(args);
}

-(void)showCustomWithFormat:(NSString *)format :(va_list)args :(BOOL)addOrDel{
    if (format!=nil&&[format isKindOfClass:[NSString class]]) {
        [self addOrDele:addOrDel tag:format];
    }
    NSString * arg = nil;
    do {
        arg = va_arg(args, NSString *);
        if (arg!=nil&&[arg isKindOfClass:[NSString class]]) {
            [self addOrDele:addOrDel tag:arg];
        }
    } while (arg);
}

-(void)addOrDele:(BOOL)add tag:(NSString *)tag{
    BOOL has = [_showTags containsObject:tag];
    if (add) {
        if (!has) {
            [_showTags addObject:tag];
        }
    }else{
        if (has) {
            [_showTags removeObject:tag];
        }
    }
}


void hmPrintf(NSMutableString* log){
    if (log.length==0) {
        return;
    }
    if ( [log rangeOfString:@"\n"].length )
	{
		[log replaceOccurrencesOfString:@"\n"
                             withString:[NSString stringWithFormat:@"\n%@", showTime?@"\t\t\t\t\t":@"\t\t"]
                                options:NSCaseInsensitiveSearch
                                  range:NSMakeRange( 0, log.length )];
	}
    
    if ( [log rangeOfString:@"%"].length) {
        
        [log replaceOccurrencesOfString:@"%" withString:@"%%" options:NSCaseInsensitiveSearch range:NSMakeRange( 0, log.length )];
    }
    
    [log appendString:@"\n"];
#if (__ON__ == __HM_LOG_CONSOLE__)
    fprintf(stderr, [log UTF8String],NULL);
#endif
    
#if (__ON__ == __HM_LOG_STROE__)
    //写日志
    
#endif
    
}

- (void)level:(NSString*)level freeFormat:(id)format, ...
{
#if (__ON__ == __HM_LOG__)
    
    if (level==nil && format==nil) {
        return;
    }
    
    NSMutableString *log = nil;
    NSString *text = nil;
    NSString *string = nil;
    NSRange range;
    if (![level isKindOfClass:[NSString class]]) {
        if ([level respondsToSelector:@selector(description)]) {
            log = [[NSMutableString alloc]initWithFormat:@"%@ [%@]\t",showTime?[dateFormatter stringFromDate:[NSDate date]]:@"",[level description]];
            
        }else{
            goto LOGEND;
        }
    }else{
        range = [level rangeOfString:@"%"];
        if (range.location!=NSNotFound) {
            NSString *arg = [level substringToIndex:range.location+2];
            string = [[NSString alloc]initWithFormat:arg,format];
            log = [[NSMutableString alloc]initWithFormat:@"%@ %@",showTime?[dateFormatter stringFromDate:[NSDate date]]:@"",string];
            
            NSString *other = [level substringFromIndex:range.location+2];
            va_list args;
            va_start( args, format );
            
            text = [[NSString alloc]initWithFormat:other arguments:args];
            
            va_end(args);
            
            [log appendString:text];
            
            goto LOGPRINTF;
        }
        if ( _enableTags && _showTags.count && ![_showTags containsObject:level] ) {
            goto LOGEND;
        }
        log = [[NSMutableString alloc]initWithFormat:@"%@ [%@]\t",showTime?[dateFormatter stringFromDate:[NSDate date]]:@"",level];
    }
    
    if (format == nil) {
        goto LOGPRINTF;
    }
    
    /// eg. output NSDictonary  only one arg
    if ( NO == [format isKindOfClass:[NSString class]] ){
        BOOL loged = NO;
        if ([format respondsToSelector:@selector(description)]) {
            
            [log appendString:[format description]];
            loged = YES;
        }
        va_list args;
        va_start( args, format );
        
        NSString * arg = nil;
        do {
            [log appendString:@" "];
            arg = va_arg(args, NSString *);
            if (arg!=nil) {
                
                if ([arg isKindOfClass:[NSString class]]) {
                    
                    if ( [arg rangeOfString:@"%"].location!=NSNotFound){
                        
                        string = [[NSString alloc]initWithFormat:arg arguments:args];
                        
                        break;
                    }
                    
                    [log appendString:arg];
                    
                }else if ([arg respondsToSelector:@selector(description)]){
                    
                    [log appendString:[arg description]];
                    
                }
            }
        } while (arg);
        
        va_end(args);
        if (string) {
            [log appendString:string];
            loged = YES;
        }
        
        if (loged) {
            goto LOGPRINTF;
        }
        
        goto LOGEND;
    }
    
    /// eg. no format like (@"my",@"test",@"log")
    if ([format rangeOfString:@"%"].location==NSNotFound) {
        
        va_list args;
        va_start( args, format );
        [log appendString:format];

        NSString * arg = nil;
        do {
            [log appendString:@" "];
            arg = va_arg(args, NSString *);
            
            if (arg!=nil) {
                
                if ([arg isKindOfClass:[NSString class]]) {
                    
                    if ( [arg rangeOfString:@"%"].location!=NSNotFound){
                        
                        string = [[NSString alloc]initWithFormat:arg arguments:args];
                        [log appendString:string];
                        
                        break;
                    }
                    
                    [log appendString:arg];
                    
                }else if ([arg respondsToSelector:@selector(description)]){
                    
                    [log appendString:[arg description]];
                    
                }
                
            }
        } while (arg);
        
        va_end( args );
	
        goto LOGPRINTF;
    }
    
    /// for normal
    
    va_list args;
    va_start( args, format );
    
    text = [[NSString alloc]initWithFormat:format arguments:args];
    
    va_end( args );
    
    [log appendString:text];

LOGPRINTF:
	hmPrintf(log);
LOGEND:
#if __has_feature(objc_arc)
    text = nil;
    log = nil;
    string = nil;
#else
    [text release];
    text = nil;
    [log release];
    log = nil;
    [string release];
    string = nil;
#endif

#endif	// #if (__ON__ == __HM_LOG__)
}

@end
