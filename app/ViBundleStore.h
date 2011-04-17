#import "ViLanguage.h"
#import "ViBundle.h"

#define ViBundleStoreBundleLoadedNotification @"ViBundleStoreBundleLoaded"

@interface ViBundleStore : NSObject
{
	NSMutableDictionary *languages;
	NSMutableArray *bundles;
	NSMutableDictionary *cachedPreferences;
}
+ (NSString *)bundlesDirectory;
+ (ViBundleStore *)defaultStore;
- (ViLanguage *)languageForFirstLine:(NSString *)firstLine;
- (ViLanguage *)languageForFilename:(NSString *)aPath;
- (ViLanguage *)languageWithScope:(NSString *)scopeName;
- (ViLanguage *)defaultLanguage;
- (NSArray *)allBundles;
- (ViBundle *)bundleWithName:(NSString *)name;
- (ViBundle *)bundleWithUUID:(NSString *)uuid;
- (NSArray *)languages;
- (NSDictionary *)preferenceItem:(NSString *)prefsName;
- (NSDictionary *)preferenceItems:(NSArray *)prefsNames;
- (NSArray *)itemsWithTabTrigger:(NSString *)name
                  matchingScopes:(NSArray *)scopes
                          inMode:(ViMode)mode
                   matchedLength:(NSUInteger *)lengthPtr;
- (NSArray *)itemsWithKeyCode:(NSInteger)keyCode
               matchingScopes:(NSArray *)scopes
                       inMode:(ViMode)mode;
- (BOOL)isBundleLoaded:(NSString *)name;
- (BOOL)loadBundleFromDirectory:(NSString *)bundleDirectory;

@end