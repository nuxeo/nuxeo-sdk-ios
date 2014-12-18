# Nuxeo SDK iOS

The goal of the iOS SDK is to integrate correctly with REST tools of the Nuxeo Platform, and provide a hierarchical synchronization service, so as to be able to access content offline.

This project is an on-going project, supported by Nuxeo.


## Adding Nuxeo iOS SDK to Your Project

### Requirements

To include Nuxeo iOS SDK as a library to your project, we recommend you use [CocoaPods](http://cocoapods.org/), a dependencies manager for Objective C projects written in Ruby and available as a [RubyGems](http://rubygems.org/gems/cocoapods).

A Nuxeo dedicated specs repository is available: [nuxeo/cocoapods-specs](https://github.com/nuxeo/cocoapods-specs).

### Adding the Lib to Your Project

After you installed CocoaPods, create a text file named `PodFile` in your project root folder.

```sh
	$ cat Podfile
	 platform :ios, '7.0'
	pod 'NuxeoSDK', :head
```

Execute the `pod` command to download or update each dependencies defined in your PodFile.

```sh
	$ pod
```

CocoaPods will create a dedicated XCode workspace containing everything you need.
    
## Accessing the REST / Automation API

Here is an example of how to fetch the `default-domain` document with its dublincore metadata from your server using the REST API:

```objc

    NSURL *url = [[NSURL alloc] initWithString:@"http://localhost:8080/nuxeo"];
    
    NUXBasicAuthenticator *auth = [[NUXBasicAuthenticator alloc] initWithUsername:@"Administrator" password:@"Administrator"];
    NUXSession *session = [[NUXSession alloc] initWithServerURL:url authenticator:auth];
    [session addDefaultSchemas:@[@"dublincore"]];
    
    NUXRequest *request = [session requestDocument:@"default-domain"];
    
    [request setCompletionBlock:^(NUXRequest *request) {
      NSError *error; 
      NUXDocument *doc = [request responseEntityWithError:&error];
      
      [self doSomethingGreatWith:doc]; 
    }];
    [request start];   
```

To access a remote server, at a first level we expose some basic objects.

* A session object, `NUXSession`, which handles connectivity, can execute a request upon a server and makes it possible to serialize JSON results as entities.
* A request object, `NUXRequest`, which enables you to parametrize your needs.

Those two objects expose HTTP concepts: you can add parameters, headers, authentication. They can be enhanced with Nuxeo concepts like schema, adaptor, category, etc.

There are several ways to execute a request. You can start it asynchrounously, synchronously (beware not to block UI thread), from the session itself, or from convenience method from the request.

### Using Authenticators

#### Default Authenticators

We provide two ways to authenticate through the Nuxeo Platform: a basic authentication and a token-based authentication. Authenticator must be set in your session object, and it handles request modification to authenticate on destination server.

* Basic authentication

It is the default one. You can also set it with a global file.

```objc
    NUXBasicAuthenticator *authenticator = [[NUXBasicAuthenticator alloc] initWithUsername:@"Administrator" password:@"Administrator"];
```

* Token-based authentication

When using token authentication, you should check `softAuthentication` to know if you already have a token, or not. If not, you should request server to ask for a new one.

```objc
    NUXTokenAuthenticator *auth = [[NUXTokenAuthenticator alloc] init];
    // Those fields are mandatory
    auth.applicationName = @"MyOwnAppName";
    auth.permission = @"rw";
    
    session.authenticator = auth;
    if (![auth softAuthentication]) {
      NUXRequest *request = [session requestTokenAuthentication];
      
      // We use the request built-in basic authentication challenge
      request.username = @"Administrator";
      request.password = @"Administrator";
      
      // Beware, request execution is asychronously.
      [auth setTokenFromRequest:nil withCompletionBlock:^(BOOL success) {
        // if success, token saved !
      }];
    } else {
      // Otherwise; you might be authenticated, but do not forget that a token could be revoked.
    }
```

#### Adding Your Own Authenticator

To add you own authenticator, you just need to use the `NUXAuthenticator` protocol.

### Available Classes

#### NUXSession Class

```objc
	#import <NuxeoSDK/NUXSession.h>
```

The `NUXSession` object goal is to handle remote server connectivity, authentication and default behaviors.

See the [NUXSession definition](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDK/Classes/NUXSession.h) and [the NUXSession tests](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDKTests/Classes/NUXSessionTests.m) for more information.

##### Shared Session

In case your application uses a single dedicated account to connect to the Nuxeo Platform, you can configure it using a resource file strictly named `NUXSession-info.plist`. Then, you'll access the singleton using the `[NUXSession shared]` message.

```xml
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Username</key>
    <string>sharedUsername</string>
    <key>Password</key>
    <string>sharedPassword</string>
    <key>Repository</key>
    <string>default</string>
    <key>ApiPrefix</key>
    <string>api/v1</string>
    <key>URL</key>
    <string>http://localhost:8080/nuxeo</string>
  </dict>
</plist>
```

##### User Level Session

if you want to use user's level sessions, you should instantiate it like other objects with the `init` message.

```objc
[[NUXSession alloc] initWithServerURL:url username:@"Administrator" password:@"Administrator"];
```

##### Changing Requests Default Behaviors

You can also change some default behavior. For instance, you can add some request's default schema or [pluggable context](http://www.nuxeo.com/blog/development/2013/09/qa-friday-video-storyboard-rest-api/) . And each request executed with this session will have those settings.

```objc
[session addDefaultSchema: @[@"dublincore", @"file"]];
[session addDefaultCategory: @[@"video"]];
```

#### NUXRequest Class

```objc
#import <NuxeoSDK/NUXRequest.h>
```

The `NUXRequest` object exposes Nuxeo concepts like schema, adaptors, categories at a document level on top of HTTP stuff like methods, headers, data. `NUXRequest` is built using a `NUXSession`.

```objc
NUXRequest *request = [[NUXRequest alloc] initWithSession:aSession];
// Nuxeo related stuff
 [request addURLSegment: @""];
 [request addAdaptor: @"children"];
 [request addAdaptor: @"blob" withValue: @"file:content"];
 [request addCategory: @"video"];
 [request addCategories: @[@"video", ...]];
 [request addSchema: @"dublincore"];
 [request addSchemas: @[@"file", ...]];
// HTTP stuff
 [request addHeaderValue:@"value" forKey:@"key"];
 [request setMethod: @"GET"];
 [request setContentType: @"application/json"];
 [request setPostData: nil];
```

`NUXRequest` can be executed synchronously or asynchronously.

```objc
[request setCompletionBlock:^(NUXRequest *request)
{ // Do some stuff }];
 [request setFailureBlock:^(NUXRequest *request) { // Do some stuff executed on failure }];
  
 [request start]; //Start request asynchrounously
 [request startSynchronous]; //Start request synchronously
  
 // Convenience method to do everything in one line
 [request startWithCompletionBlock:^(NUXRequest *request) { // Do some stuff }FailureBlock:^(NUXRequest *request)
{ // Do some stuff executed on failure }];
```

See the [NXRequest definition](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDK/Classes/Requests/NUXRequest.h) and the [NUXRequest tests](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDKTests/Classes/NUXRequestTests.m) for more information.

### Response Handling

There are several ways to get response data:

* **NSData**: Passing the HTTP result as it comes, as an object-oriented wrapper for byte buffer.
* **NSString**: Building a string with the NSData object. The expected response string is UTF8 encoded.
* **JSON as NSDictionnary**: Serializing response in a JSON object.
* **NUXEntity**: using our custom serialization object, to fill a custom object depending of the `entity-type` JSON field.

Here is a code sample:

```objc
[request startSynchronous];
// Reponse
 request.responseStatusCode;
 request.responseMessage;
NSData *data = [request responseData];
 NSString *string = [request responseString];
NSError *error;
 NSDictionnary *json = [request responseJSONWithError:&error];
 NUXEntity *entity = [request responseEntityWithError:&error];
```

### Downloading Blobs

When you know your response will be a file, instead of mounting the complete file in memory in the `data` field of your request object, you must set the `downloadDestinationPath` property to stream the response data into it.

```objc
NSString *tempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tempfile%d.tmp", rand()]];
 request = [session requestDownloadBlobFrom:uid inMetadata:@"file:content"];
 request.downloadDestinationPath = tempFile;
Icon
```

Use differents queues to make sure downloading a file is not blocking other requests. It also allows you to cancel downloads and let other requests finish their work.

## Entity Mapping

Here is an example to register a new entity type:

1. Run the following:
```objc
    [[NUXJSONMApper sharedMapper] registerEntityClass:[OWNEntity class]];
```
    
2. Map the request response to the new entity from the response `entity-type` JSON field:
```objc
    NSError *error;
    OWNEntity *doc = [request responseEntityWithError:&error];
```

3. Implement `NUXEntityPersistable` protocol to allow your class to be persisted.

To manipulate a JSON response as an object instead of a `NSDictionnary` class, an automatic introspection mapping based on the entity-type value is available: each existing property is filled in the object mapping.

Each entity class must be registered as such and extend at least `NUXEntity`. We provide entity classes for base entity-type (`document` and `documents`), but you could register any entity for your custom [business objects](http://doc.nuxeo.com/display/NXDOC/Repository+Concepts#RepositoryConcepts-DocumentModel-adpater).

To convert `NSData` to `NUXEntity`, or `NUXEntity` to `NSData`:

```objc
NSError *error;
NUXDocument *entity = [NUXJSONSerializer entityWithData:someData error:&error];
NSData *data = [NUXJSONSerializer dataWithEntity:entity error:&error];
```

See the [NUXJSONSerializer tests](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDKTests/Classes/NUXJSONSerializerTests.m) for more information.

## Convenience Category to Generate Common Requests

```objc
import <NuxeoSDK/NUXSession+requests.h>
```

A category `NUXSession+requests.h` is available to add some common requests to a `NUXSession` object. This makes it easier to generate requests with fetchDocument, get document children, query, etc.

Here is a sample of convenience method:

```objc
// Prefilled request messages
 NUXRequest *request = [session requestDocument: @"uid|path"];
request = [session requestChildren: @"uid|path"];
 request = [session requestQuery: @"SELECT * FROM Folder"];
// You can pass JSON dictionnary or NUXEntity
 [session requestUpdateDocument: myDoc];
 [session requestDeleteDocument: myDoc];
 [session requestCreateDocument: myDoc withParent: @"/default-domain"];
```
See the [NUXSession+requests.h definition](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDK/Classes/NUXSession+requests.h) and the [NUXSession tests](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDKTests/Classes/NUXSessionTests.m) for more information.

### Automation Requests

We define a specific request for calling Automation operations. It exposes more Automation concepts like operation input (with a document or a file), operation context and operation parameters.

```objc
NUXAutomationRequest *request = [session requestOperation:@"FileManager.Import"];
 [request addContextValue:@"/default-domain/workspaces" forKey:@"currentDocument"];
 [request setInputFile:aFilePath];
// or more simply
 request = [session requestImportFile:file withParent:@"/default-domain/workspaces"];
```

## Cache

### Document, Document Listing Cache

To cache document response based on their entity type, you can use:

```objc

    NUXEntityCache *cache = [NUXEntityCache instance];
    // Write entity in cache
    [cache writeEntity:doc];
    
    // Read entity from the cache
    [cache hasEntityWithId:@"4242-4242-4342" class:[NUXDocument class]]);
    NUXDocument *ent = [[cache entityWithId:@"4242-4242-4342" class:[NUXDocument class]]);
    
```
    
To manipulate document listing, there is the same kind of API:

```objc
    // Save
    [cache saveEntities:entitiesArray withListName:@"myListName" error:nil];
    NSArray *cached = [cache entitiesFromList:@"myListName"];
```

### Hierarchical Cache

Hierarchical cache is initialized with one request to define the hierarchy nodes. Then for each node you can define a block to fill its content. Nodes and content are stored in a SQLite database and available offline. Content could be refreshed automatically when online (default behavior).

Each hierarchy is identified with a unique name.

Here is a sample to initialize a hierarchy.

Don't forget to initiate it with blocks at your application startup, even if you don't need to load it at a time and even if `loadWithRequest` takes into account if the hierarchy is loaded or not.

```objc
NUXHierarchy *hierarchy = [NUXHierarchy hierarchyWithName:@"mainHierarchy"];
 NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
 [hierarchy loadWithRequest:request]; //loading is asynchronous
[hierarchy waitUntilLoadingIsDone]; //exists, if you really need it.
```

In this sample, no content block is defined, so you'll have to manage your node content outside of the hierarchy mecanism. After this async initialization, you'll be able to browse nodes, for instance.


```objc
hierarchy.childrenOfRoot; // Return all root nodes
 [hierarchy childrenOfDocument:@"/default-domain"]; // Assuming your request has loaded /default-domain
If you want to use the provided node's content management, you just have to define a content block like this:
NUXHierarchy *hierarchy = [NUXHierarchy hierarchyWithName:@"mainHierarchy"];
 hierarchy.nodeBlock = ^NSArray *(NUXEntity *entity, NSUInteger depth)
 {
 NUXDocument *doc = (NUXDocument *)entity;
 if ([self shouldLoadDocumentsForNode:doc withDepth:depth] == YES)
{
 NUXSession *nuxSession = [NUXSession sharedSession]; // retrieve all
documents in this node in synchronize mode NSString *subRequestFormat =
@"SELECT * FROM Document where ecm:parentId = '%@'and ecm:currentLifeCycleState <> 'deleted'"; NSString *subRequestQuery = [NSString stringWithFormat:subRequestFormat, doc.uid]; NUXRequest *nuxSubRequest = [nuxSession requestQuery:subRequestQuery]; [nuxSubRequest startSynchronous]; NUXDocuments *documents = [nuxSubRequest responseEntityWithError:nil]; return documents.entries; }return nil;
 };
NUXRequest *request = [session requestQuery:@"select * from Document where ecm:mixinType = 'Folderish'"];
 [hierarchy loadWithRequest:request]; //loading is asynchronous
```

The goal of a `nodeBlock` is to return an array of documents that you want to get as the content of a node. Note that `nodeBlock` is executed in a separate thread, so if you want to get documents from a request, you have to start it synchronously.

While you are online, the same block is called each time you get content.

### Blob LRU Cache


We provide a LRU cache to easily store your blob with an API-oriented `NUXEntity` or digest. You can change the maximum size and maximum items in cache. Size is defined in bytes.

```objc
[NUXBlobStore instance].sizeLimit = @(2*1024*1024*1024); // Set cache limit to 2Go
[NUXBlobStore instance].countLimit = @(10); // Set item limit to 10.
```

`NUXBlobStore` removes the least recently used items first. Default values are unlimited size and 100 items. It uses blob digest as a key store. You can test if a blob is present, save a new blob, delete a specific blob from cache or reset the whole cache.

```objc
// Saving a blob
 NSString *storePath = [[NUXBlobStore instance] saveBlobFromPath:filePath withDocument:doc metadataXPath:@"file:content"];
// Accessing a blob with his digest
 NSString *digest = [[doc.properties valueForKey:@"file:content"] valueForKey:@"digest"];
 NSString *blobPath = [[NUXBlobStore instance] blob:digest];
 // Removing blob
 [[NUXBlobStore instance] removeBlob:digest];
```
 
**Notes**

The blob store does not directly handle blob download. You have to do it with a specific request. But, as soon as the blob is downloaded you can save it inside the blob store.

See the [NUXBlobStore tests](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDKTests/Classes/NUXBlobStoreTests.m) for more information.

## For Development

### Building Nuxeo SDK iOS

#### Requirements

To include Nuxeo SDK as a library to your project, we recommend you use [CocoaPods](http://cocoapods.org/), a dependencies manager for Objective C projects written in Ruby and available as a [RubyGems](http://rubygems.org/gems/cocoapods).

A Nuxeo dedicated specs repository is available: [nuxeo/cocoapods-specs](https://github.com/nuxeo/cocoapods-specs).

#### How to Build
If you want 

After you installed CocoaPods, run:

```sh

    # Adding our cocoapods specs repository
    $ pod repo add nuxeo https://github.com/nuxeo/cocoapods-specs
    
    # Executing `pod` to fetch dependencies
    $ cd NuxeoSDK
    $ pod
    $ open NuxeoSDK.xcworkspace
    
```

### QA Scripts

There are two scripts to help automatically test the project.

#### build-and-test.sh

This script is based on [Nuxeo integration scripts](https://github.com/nuxeo/integration-scripts). It downloads and starts the latest built nuxeo-distribution and executes the test suite using [xctool](https://github.com/nuxeo/integration-scripts), a Facebook's script to prettify XCode output.

#### prepare-pod.sh

This script includes a few commands to install pods dependencies.

## Resources

### QA Results

Follow the project build status on [http://qa.nuxeo.org/jenkins/job/nuxeo-sdk-ios-master/](http://qa.nuxeo.org/jenkins/job/nuxeo-sdk-ios-master/).

### Reporting Issues

You can follow the developments in the Nuxeo Platform project of our JIRA bug tracker, which includes a iOS SDK component: [https://jira.nuxeo.com/browse/NXP/component/13404](https://jira.nuxeo.com/browse/NXP/component/13404).

You can report issues  directly [from the GitHub project](https://github.com/nuxeo/nuxeo-sdk-ios/issues).

## About Nuxeo

Nuxeo dramatically improves how content-based applications are built, managed and deployed, making customers more agile, innovative and successful. Nuxeo provides a next generation, enterprise ready platform for building traditional and cutting-edge content oriented applications. Combining a powerful application development environment with SaaS-based tools and a modular architecture, the Nuxeo Platform and Products provide clear business value to some of the most recognizable brands including Verizon, Electronic Arts, Netflix, Sharp, FICO, the U.S. Navy, and Boeing. Nuxeo is headquartered in New York and Paris. More information is available at [www.nuxeo.com](http://www.nuxeo.com/).
