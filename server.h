@interface BruhShotsTMServer : NSObject {
	CPDistributedMessagingCenter * _messagingCenter;
}
@property (nonatomic, retain) NSMutableDictionary * configuration;
@property (nonatomic, retain) NSArray * supportedMessageNames;
@end