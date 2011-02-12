//
//  AppController.m
//  MGTwitterEngine
//
//  Created by Matt Gemmell on 10/02/2008.
//  Copyright 2008 Instinctive Code.
//

#import "AppController.h"

@implementation AppController

NSString *consumerKey = ;
NSString *consumerSecret = ;

-(void)runTestsWithToken:(OAToken*)aToken {
    // Create a TwitterEngine and set credentials
    twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine setUsesSecureConnection:NO];
	[twitterEngine setConsumerKey:consumerKey secret:consumerSecret];
	[twitterEngine setAccessToken:aToken];
	 
	[self runTests];
}


-(void)requestOAuthToken {
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret] autorelease];
	
    NSURL *url;
	SEL ticketFinish;
	SEL ticketFail;
	
	if(_requestToken) {
		url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
		ticketFinish = @selector(accessTokenTicket:didFinishWithData:);
		ticketFail = @selector(accessTokenTicket:didFailWithError:);
	} else {
		url = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
		ticketFinish = @selector(requestTokenTicket:didFinishWithData:);
		ticketFail = @selector(requestTokenTicket:didFailWithError:);
	}

    [_request release];
	_request = [[OAMutableURLRequest alloc] initWithURL:url
											   consumer:consumer
												  token:_requestToken   // we don't have a Token yet
												  realm:nil   // our service provider doesn't specify a realm
									  signatureProvider:nil]; // use the default method, HMAC-SHA1
	
	[_request setHTTPMethod:@"POST"];
	_request.callback = @"myscheme:/OAuth";

    [_fetcher release];
	_fetcher = [[OADataFetcher alloc] init];
	[_fetcher fetchDataWithRequest:_request
							 delegate:self
					didFinishSelector:ticketFinish
					  didFailSelector:ticketFail];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	
	[self requestOAuthToken];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
	// TODO: clean up
    NSString* s = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	NSURL *url = [NSURL URLWithString:s];
	
	NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString* param in [[url query] componentsSeparatedByString:@"&"]) {
		NSArray* elts = [param componentsSeparatedByString:@"="];
		[params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
	}
	NSString *verifier = [params objectForKey:@"oauth_verifier"];
    _requestToken.verifier = verifier;
	[self requestOAuthToken];
    }
    
- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *responseBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if (ticket.didSucceed) {
		_requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
	 
		NSString *s = [NSString stringWithFormat: @"https://api.twitter.com/oauth/authorize?oauth_token=%@", _requestToken.key];
		NSURL *url = [NSURL URLWithString:s];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	NSString *responseBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if (ticket.didSucceed) {
		OAToken *t = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
		[self runTestsWithToken: t];
	}
}
	
-(void)runTests{
	// Configure how the delegate methods are called to deliver results. See MGTwitterEngineDelegate.h for more info
	//[twitterEngine setDeliveryOptions:MGTwitterEngineDeliveryIndividualResultsOption];

	// Get the public timeline
	//NSLog(@"getPublicTimelineSinceID: connectionIdentifier = %@", [twitterEngine getPublicTimeline]);

	// Other types of information available from the API:
	
	#define TESTING_ID 1131604824
	#define TESTING_PRIMARY_USER @"gnitset"
	#define TESTING_SECONDARY_USER @"chockenberry"
	#define TESTING_MESSAGE_ID 52182684
	
	// Status methods:
//	NSLog(@"getHomeTimelineFor: connectionIdentifier = %@", [twitterEngine getHomeTimelineSinceID:0 startingAtPage:0 count:20]);
//	NSLog(@"getUserTimelineFor: connectionIdentifier = %@", [twitterEngine getUserTimelineFor:TESTING_SECONDARY_USER sinceID:0 startingAtPage:0 count:3]);
//	NSLog(@"getUpdate: connectionIdentifier = %@", [twitterEngine getUpdate:TESTING_ID]);
	NSLog(@"sendUpdate: connectionIdentifier = %@", [twitterEngine sendUpdate:[@"This is a test on " stringByAppendingString:[[NSDate date] description]]]);
//	NSLog(@"getRepliesStartingAtPage: connectionIdentifier = %@", [twitterEngine getRepliesStartingAtPage:0]);
	//NSLog(@"deleteUpdate: connectionIdentifier = %@", [twitterEngine deleteUpdate:TESTING_ID]);

	// User methods:
	//NSLog(@"getRecentlyUpdatedFriendsFor: connectionIdentifier = %@", [twitterEngine getRecentlyUpdatedFriendsFor:nil startingAtPage:0]);
	//NSLog(@"getFollowersIncludingCurrentStatus: connectionIdentifier = %@", [twitterEngine getFollowersIncludingCurrentStatus:YES]);
	//NSLog(@"getUserInformationFor: connectionIdentifier = %@", [twitterEngine getUserInformationFor:TESTING_PRIMARY_USER]);
														  
	// Direct Message methods:
	NSLog(@"getDirectMessagesSinceID: connectionIdentifier = %@", [twitterEngine getDirectMessagesSinceID:0 startingAtPage:0]);
	//NSLog(@"getSentDirectMessagesSinceID: connectionIdentifier = %@", [twitterEngine getSentDirectMessagesSinceID:0 startingAtPage:0]);
	//NSLog(@"sendDirectMessage: connectionIdentifier = %@", [twitterEngine sendDirectMessage:[@"This is a test on " stringByAppendingString:[[NSDate date] description]] to:TESTING_SECONDARY_USER]);
	//NSLog(@"deleteDirectMessage: connectionIdentifier = %@", [twitterEngine deleteDirectMessage:TESTING_MESSAGE_ID]);


	// Friendship methods:
	//NSLog(@"enableUpdatesFor: connectionIdentifier = %@", [twitterEngine enableUpdatesFor:TESTING_SECONDARY_USER]);
	//NSLog(@"disableUpdatesFor: connectionIdentifier = %@", [twitterEngine disableUpdatesFor:TESTING_SECONDARY_USER]);
	//NSLog(@"isUser:receivingUpdatesFor: connectionIdentifier = %@", [twitterEngine isUser:TESTING_SECONDARY_USER receivingUpdatesFor:TESTING_PRIMARY_USER]);


	// Account methods:
	//NSLog(@"checkUserCredentials: connectionIdentifier = %@", [twitterEngine checkUserCredentials]);
	//NSLog(@"endUserSession: connectionIdentifier = %@", [twitterEngine endUserSession]);
	//NSLog(@"setLocation: connectionIdentifier = %@", [twitterEngine setLocation:@"Playing in Xcode with a location that is really long and may or may not get truncated to 30 characters"]);
	//NSLog(@"setNotificationsDeliveryMethod: connectionIdentifier = %@", [twitterEngine setNotificationsDeliveryMethod:@"none"]);
	// TODO: Add: account/update_profile_colors
	// TODO: Add: account/update_profile_image
	// TODO: Add: account/update_profile_background_image
	//NSLog(@"getRateLimitStatus: connectionIdentifier = %@", [twitterEngine getRateLimitStatus]);
	// TODO: Add: account/update_profile

	// Favorite methods:
	//NSLog(@"getFavoriteUpdatesFor: connectionIdentifier = %@", [twitterEngine getFavoriteUpdatesFor:nil startingAtPage:0]);
	//NSLog(@"markUpdate: connectionIdentifier = %@", [twitterEngine markUpdate:TESTING_ID asFavorite:YES]);

	// Notification methods
	//NSLog(@"enableNotificationsFor: connectionIdentifier = %@", [twitterEngine enableNotificationsFor:TESTING_SECONDARY_USER]);
	//NSLog(@"disableNotificationsFor: connectionIdentifier = %@", [twitterEngine disableNotificationsFor:TESTING_SECONDARY_USER]);

	// Block methods
	//NSLog(@"block: connectionIdentifier = %@", [twitterEngine block:TESTING_SECONDARY_USER]);
	//NSLog(@"unblock: connectionIdentifier = %@", [twitterEngine unblock:TESTING_SECONDARY_USER]);

	// Help methods:
	//NSLog(@"testService: connectionIdentifier = %@", [twitterEngine testService]);
	
	// Social Graph methods
	//NSLog(@"getFriendIDsFor: connectionIdentifier = %@", [twitterEngine getFriendIDsFor:TESTING_SECONDARY_USER startingFromCursor:-1]);
	//NSLog(@"getFollowerIDsFor: connectionIdentifier = %@", [twitterEngine getFollowerIDsFor:TESTING_SECONDARY_USER startingFromCursor:-1]);

#if YAJL_AVAILABLE || TOUCHJSON_AVAILABLE
	// Search method
	//NSLog(@"getSearchResultsForQuery: connectionIdentifier = %@", [twitterEngine getSearchResultsForQuery:TESTING_PRIMARY_USER sinceID:0 startingAtPage:1 count:20]);
	
	// Trends method
	//NSLog(@"getTrends: connectionIdentifier = %@", [twitterEngine getTrends]);
#endif
}

- (void)dealloc
{
    [twitterEngine release];
    [super dealloc];
}


#pragma mark MGTwitterEngineDelegate methods


- (void)requestSucceeded:(NSString *)connectionIdentifier
{
    NSLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);
}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    NSLog(@"Request failed for connectionIdentifier = %@, error = %@ (%@)", 
          connectionIdentifier, 
          [error localizedDescription], 
          [error userInfo]);
}


- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier
{
    NSLog(@"Got statuses for %@:\r%@", connectionIdentifier, statuses);
}


- (void)directMessagesReceived:(NSArray *)messages forRequest:(NSString *)connectionIdentifier
{
    NSLog(@"Got direct messages for %@:\r%@", connectionIdentifier, messages);
}


- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier
{
    NSLog(@"Got user info for %@:\r%@", connectionIdentifier, userInfo);
}


- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"Got misc info for %@:\r%@", connectionIdentifier, miscInfo);
}


- (void)searchResultsReceived:(NSArray *)searchResults forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"Got search results for %@:\r%@", connectionIdentifier, searchResults);
}


- (void)socialGraphInfoReceived:(NSArray *)socialGraphInfo forRequest:(NSString *)connectionIdentifier
{
	NSLog(@"Got social graph results for %@:\r%@", connectionIdentifier, socialGraphInfo);
}


- (void)imageReceived:(NSImage *)image forRequest:(NSString *)connectionIdentifier
{
    NSLog(@"Got an image for %@: %@", connectionIdentifier, image);
    
    // Save image to the Desktop.
    NSString *path = [[NSString stringWithFormat:@"~/Desktop/%@.tiff", connectionIdentifier] stringByExpandingTildeInPath];
    [[image TIFFRepresentation] writeToFile:path atomically:NO];
}

- (void)connectionFinished:(NSString *)connectionIdentifier
{
    NSLog(@"Connection finished %@", connectionIdentifier);

	if ([twitterEngine numberOfConnections] == 0)
	{
		[NSApp terminate:self];
	}
}

#if YAJL_AVAILABLE || TOUCHJSON_AVAILABLE

- (void)receivedObject:(NSDictionary *)dictionary forRequest:(NSString *)connectionIdentifier
{
    NSLog(@"Got an object for %@: %@", connectionIdentifier, dictionary);
}

#endif

@end
