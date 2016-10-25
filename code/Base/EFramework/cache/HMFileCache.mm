

#import "HMFileCache.h"
#import "HMSandbox.h"
#import "HMSystemInfo.h"
#import "HMRuntime.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@interface HMFileCache()
{
	NSString *	_cachePath;
}
@end

#pragma mark -

@implementation HMFileCache

@synthesize cachePath = _cachePath;
@synthesize userDir = _userDir;

DEF_SINGLETON( HMFileCache );

- (id)init
{
	self = [super init];
	if ( self )
	{
		self.cachePath = [NSString stringWithFormat:@"%@/Cache/", [HMSandbox libCachePath]];
	}
	return self;
}

- (void)setUserDir:(NSString *)userDir{
#if  __has_feature(objc_arc)
    _userDir = userDir;
#else
    [_userDir release];
    _userDir = [userDir copy];
#endif
   
    if (_userDir) {
        self.cachePath = [NSString stringWithFormat:@"%@/Cache/%@/", [HMSandbox libCachePath] ,_userDir];
    }
    
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];

	self.cachePath = nil;
    self.userDir= nil;
	HM_SUPER_DEALLOC();
}

- (unsigned long long)fileSizeForPath:(NSString *)path {
    
    signed long long fileSize = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

- (unsigned long long)fileSizeForDirectory:(NSString *)dic{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:dic]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:dic] objectEnumerator];
    NSString* fileName;
    unsigned long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [dic stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeForPath:fileAbsolutePath];
    }
    return folderSize;
}

- (unsigned long long)fileSizeForKey:(NSString *)key branch:(NSString *)branch {
    
    NSString *path = [self fileNameForKey:key branch:branch];
    BOOL isdire = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isdire]) {
        if (isdire) {
            return  [self fileSizeForDirectory:path];
        }else{
            return  [self fileSizeForPath:path];
        }
    }
    return 0;
}

- (NSString *)fileNameForKey:(NSString *)key{
    
    return [self fileNameForKey:key branch:nil];
    
}

- (NSString *)fileNameForKey:(NSString *)key branch:(NSString *)branch
{
	NSString * pathName = nil;
	if ( branch && [branch length] )
	{
		pathName = [self.cachePath stringByAppendingFormat:@"%@/", branch];
	}
	else
	{
		pathName = self.cachePath;
	}
	
	if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:pathName] )
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:pathName
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
    if (key) {
        pathName = [pathName stringByAppendingString:key];
    }
	return pathName;
}

- (BOOL)moveItemForKey:(NSString *)key atBranch:(NSString *)at toBranch:(NSString *)to{
    
    return [[NSFileManager defaultManager] moveItemAtPath:[self fileNameForKey:key branch:at] toPath:[self fileNameForKey:key branch:to] error:Nil];
    
}

- (BOOL)hasObjectForKey:(id)key{
    
    return [self hasObjectForKey:key branch:nil];
    
}

- (BOOL)hasObjectForKey:(id)key branch:(NSString *)branch
{
    if (key==nil) {
        return NO;
    }
	return [[NSFileManager defaultManager] fileExistsAtPath:[self fileNameForKey:key branch:branch]];
}

- (id)objectForKey:(id)key{
    
    return [self objectForKey:key branch:nil];
    
}

- (id)objectForKey:(id)key branch:(NSString *)branch
{
    if (key==nil) {
        return nil;
    }
	NSData * data = [NSData dataWithContentsOfFile:[self fileNameForKey:key branch:branch] options:NSDataReadingMappedIfSafe error:nil];
	return data;
}

- (void)setObject:(id)object forKey:(id)key{
    [self setObject:object forKey:key branch:nil];
}
- (void)setObject:(id)object forKey:(id)key branch:(NSString *)branch
{
    if (key==nil) {
        return;
    }
	if ( nil == object )
	{
		[self removeObjectForKey:key branch:branch];
	}
	else
	{
		NSData * data = nil;
		
		if ( [object isKindOfClass:[NSData class]] )
		{
			data = (NSData *)object;
		}
		else
		{
			data = [self serialize:object];
		}
	
        NSString *path = [self fileNameForKey:key branch:branch];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [data writeToFile:path
                      options:NSDataWritingAtomic
                        error:NULL];
        });
		
	}
}
-(void)removeObjectForKey:(id)key branch:(NSString *)branch{
    [[NSFileManager defaultManager] removeItemAtPath:[self fileNameForKey:key branch:branch] error:nil];
}

- (void)removeObjectForKey:(NSString *)key
{
	[self removeObjectForKey:key branch:nil];
}

- (void)removeAllObjectsForBranch:(NSString *)branch{
    NSString * pathName = nil;
	if ( branch && [branch length] )
	{
		pathName = [self.cachePath stringByAppendingFormat:@"%@/", branch];
	}
	else
	{
		pathName = self.cachePath;
	}
#if (__ON__ == __HM_DEVELOPMENT__)
    CC(@"Caches",@"remove",pathName);
#endif
    [[NSFileManager defaultManager] removeItemAtPath:pathName error:NULL];
	[[NSFileManager defaultManager] createDirectoryAtPath:pathName
							  withIntermediateDirectories:YES
											   attributes:nil
													error:NULL];
}

+ (void)removeAllImageCaches{
    
    [[HMFileCache sharedInstance] removeAllObjectsForBranch:@"images"];
    
}

+ (void)removeAllWebApiCaches{
    
    [[HMFileCache sharedInstance] removeAllObjectsForBranch:@"HMWebAPI"];
    
}

+ (void)removeAllWebViewCaches{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)removeAllObjects
{
	[self removeAllObjectsForBranch:nil];
}

- (NSData *)serialize:(id)obj
{
	if ( [obj isKindOfClass:[NSData class]] )
		return obj;
	
	if ( [obj respondsToSelector:@selector(encodeWithCoder:)] )
		return [obj objectToData];
	
	return nil;
}

- (id)unserialize:(NSData *)data
{
	return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];;
}

@end

#define FileHashDefaultChunkSizeForReadingData 1024*8
HM_EXTERN_C_BEGIN

CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    
    // Declare needed variables
    
    CFStringRef result = NULL;
    
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    
    CFURLRef fileURL =
    
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  
                                  (CFStringRef)filePath,
                                  
                                  kCFURLPOSIXPathStyle,
                                  
                                  (Boolean)false);
    
    if (!fileURL)return result;
    
    // Create and open the read stream
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            
                                            (CFURLRef)fileURL);
    
    if (!readStream) {
        if (fileURL) {
            
            CFRelease(fileURL);
            
        }
        return result;
    }
    
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    
    if (!didSucceed){
        if (readStream) {
            
            CFReadStreamClose(readStream);
            
            CFRelease(readStream);
            
        }
        
        if (fileURL) {
            
            CFRelease(fileURL);
            
        }
        
        return result;
    }
    
    // Initialize the hash object
    
    CC_MD5_CTX hashObject;
    
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    
    if (!chunkSizeForReadingData) {
        
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
        
    }
    
    // Feed the data to the hash object
    
    bool hasMoreData = true;
    
    while (hasMoreData) {
        
        uint8_t buffer[chunkSizeForReadingData];
        
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        
        if (readBytesCount == -1) break;
        
        if (readBytesCount == 0) {
            
            hasMoreData = false;
            
            continue;
            
        }
        
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
        
    }
    
    // Check if the read operation succeeded
    
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    
    if (!didSucceed){
        if (readStream) {
            
            CFReadStreamClose(readStream);
            
            CFRelease(readStream);
            
        }
        
        if (fileURL) {
            
            CFRelease(fileURL);
            
        }
        
        return result;
    }
    
    // Compute the string result
    
    char hash[2 * sizeof(digest) + 1];
    
    for (size_t i = 0; i < sizeof(digest); ++i) {
        
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        
    }
    
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
    if (readStream) {
        
        CFReadStreamClose(readStream);
        
        CFRelease(readStream);
        
    }
    
    if (fileURL) {
        
        CFRelease(fileURL);
        
    }
    
    return result;
    
}

NSString* getFileMD5WithPath(NSString* path)
{
    
    return (__bridge_transfer_type NSString *)FileMD5HashCreateWithPath((__bridge_type CFStringRef)path, FileHashDefaultChunkSizeForReadingData);
    
}
void checkFileMD5With(NSString* path,NSString *md5,void(^Checked)(BOOL,NSString *)){
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fileMd5 = getFileMD5WithPath(path);
        if (Checked) {
            Checked(YES,fileMd5);
        }
        SAFE_RELEASE(fileMd5);
    });
    
}

HM_EXTERN_C_END

@implementation NSData(MD5Extension)

@dynamic MD5;
@dynamic MD5String;

- (NSData *)MD5
{
	unsigned char	md5Result[CC_MD5_DIGEST_LENGTH + 1];
	CC_LONG			md5Length = (CC_LONG)[self length];
	
	CC_MD5( [self bytes], md5Length, md5Result );
	
	
	
#if  __has_feature(objc_arc)
    NSMutableData * retData = [[NSMutableData alloc] init];
#else
    NSMutableData * retData = [[[NSMutableData alloc] init] autorelease];
#endif
	if ( nil == retData )
		return nil;
	
	[retData appendBytes:md5Result length:CC_MD5_DIGEST_LENGTH];
	return retData;
}

- (NSString *)MD5String
{
	NSData * value = [self MD5];
	if ( value )
	{
		char			tmp[16];
		unsigned char *	hex = (unsigned char *)malloc( 2048 + 1 );
		unsigned char *	bytes = (unsigned char *)[value bytes];
		unsigned long	length = [value length];
		
		hex[0] = '\0';
		
		for ( unsigned long i = 0; i < length; ++i )
		{
			sprintf( tmp, "%02X", bytes[i] );
			strcat( (char *)hex, tmp );
		}
		
		NSString * result = [NSString stringWithUTF8String:(const char *)hex];
		free( hex );
		return result;
	}
	else
	{
		return nil;
	}
}

@end

@implementation NSString(MD5Extension)

@dynamic MD5;
@dynamic MD5String;

- (NSData *)MD5{
    NSData *data = [NSData dataWithBytes:self.UTF8String length:self.length];
    return  [data MD5];
}

- (NSString *)MD5String{
    NSData *data = [NSData dataWithBytes:self.UTF8String length:self.length];
    return  [data MD5String];
}


@end
