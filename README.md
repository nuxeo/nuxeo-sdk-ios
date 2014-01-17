# Nuxeo SDK iOS

Toolbox to provides a library to start building your iOS application connected to Nuxeo through our [REST API](http://doc.nuxeo.com/x/QYLQ).

## How to build

You need to install [cocoapods](http://cocoapods.org/):

    # Adding our cocoapods specs repository
    $ pod repo add nuxeo https://github.com/nuxeo/cocoapods-specs
    
    # Executing `pod` to fetch dependencies
    $ cd NuxeoSDK
    $ pod
    $ open NuxeoSDK.xcworkspace
    
## API Provided

You can find the whole documentation about what you can do with this library and access your server with the REST API in the [documentation center](http://doc.nuxeo.com/display/MAIN/Nuxeo+Documentation+Center+Home) in the [iOS Client](http://doc.nuxeo.com/display/NXDOC/iOS+Client) part.

### REST / Automation API

[Documentation about REST / Automation API](http://doc.nuxeo.com/x/2Ir1#iOSClient-AccessingREST%2FAutomationAPI)

A simple example how to fetch `default-domain` from your server using REST API:

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

### Authenticators

For now we provide two way to authenticate through Nuxeo; you can add your own using `NUXAuthenticator` protocol.
Authenticator must be set in your session object, and it handles request modification to authenticate on destination server.

* Basic authentication

The default one, you can also set it with a global file.

    NUXBasicAuthenticator *authenticator = [[NUXBasicAuthenticator alloc] initWithUsername:@"Administrator" password:@"Administrator"];

* Token based authentication

When using token authentication, you should check `softAuthentication` to know if you already have a token, or not. If not, you should request server to ask for a new one.

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


### Entity Mapping

[Documentation about entity mapping](http://doc.nuxeo.com/x/2Ir1#iOSClient-ObjectMapping)

We provide a simple way to register entities and map them to query results. To register a new entity type, just do as follow:

    [[NUXJSONMApper sharedMapper] registerEntityClass:[OWNEntity class]];
    
Then to map request response to an existing entity, resoluton is based on response `entity-type` JSON field:

    NSError *error;
    OWNEntity *doc = [request responseEntityWithError:&error];

### Hiearchical cache

[Documentation about hiearchical cache](http://doc.nuxeo.com/x/2Ir1#iOSClient-HierarchicalCache)

### Blob store

[Documentation about LRU blob cache](http://doc.nuxeo.com/x/2Ir1#iOSClient-BlobLRUcache)

Blob store do not handles directly blob download, you have to do it with a specific request. But, as soon as the blob is downloaded you can save it inside the blob store like this:

    NSError* error;
    [bs saveBlobFromPath:filePath withDocument:doc metadataXPath:@"file:content" error:&error];
    
And retrieve it with:
  
    NSString* blobPath = [bs blobFromDocument:doc metadataXPath:@"file:content"];
    
### Document, Document listing cache

To cache document response based on their entity type, you can use:

    NUXEntityCache *cache = [NUXEntityCache instance];
    # Write entity in cache
    [cache writeEntity:doc];
    
    # Read entity from the cache
    [cache hasEntityWithId:@"4242-4242-4342" class:[NUXDocument class]]);
    NUXDocument *ent = [[cache entityWithId:@"4242-4242-4342" class:[NUXDocument class]]);
    
To manipulate document listing, there is the same kind of API:

    # Save
    [cache saveEntities:entitiesArray withListName:@"myListName" error:nil];
    NSArray *cached = [cache entitiesFromList:@"myListName"];


## QA Scripts

There are two scripts to help to automaticly testing the project

### build-and-test.sh

This script is based on [Nuxeo integration scripts](https://github.com/nuxeo/integration-scripts). It downloads, start the latest built nuxeo-distribution and execute the test suite using [xctool](https://github.com/nuxeo/integration-scripts), a Facebook's script to prettify XCode output.

### prepare-pod.sh

Just a few commands to install pods dependencies

## About Nuxeo

Nuxeo provides a modular, extensible Java-based [open source software platform for enterprise content management](http://www.nuxeo.com/en/products/ep) and packaged applications for [document management](http://www.nuxeo.com/en/products/document-management), [digital asset management](http://www.nuxeo.com/en/products/dam) and [case management](http://www.nuxeo.com/en/products/case-management). Designed by developers for developers, the Nuxeo platform offers a modern architecture, a powerful plug-in model and extensive packaging capabilities for building content applications.

More information on: <http://www.nuxeo.com/>
