# Nuxeo SDK iOS - CHANGELOG

## API Changes from 0.2.0 to 0.3.0

### [NXP-13558](https://jira.nuxeo.com/browse/NXP-13558) Authentication challenges

Basic authentication username/password are no longer exposes on `NUXSession`. 
`NUXSession` is now using a [NUXAuthenticator](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDK/Classes/Authentication/NUXAuthenticator.h): 

 - [NUXBasicAuthenticator](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDK/Classes/Authentication/NUXBasicAuthenticator.h)
 - [NUXTokenAuthenticator](https://github.com/nuxeo/nuxeo-sdk-ios/blob/master/NuxeoSDK/NuxeoSDK/Classes/Authentication/NUXTokenAuthenticator.h)
 
Sample:

    NUXBasicAuthenticator *authenticator = [[NUXBasicAuthenticator alloc] initWithUsername:@"Administrator" password:@"Administrator"];
    NUXSession session = [[NUXSession alloc] initWithServerURL:url authenticator:authenticator];

## About Nuxeo

Nuxeo provides a modular, extensible Java-based [open source software platform for enterprise content management](http://www.nuxeo.com/en/products/ep) and packaged applications for [document management](http://www.nuxeo.com/en/products/document-management), [digital asset management](http://www.nuxeo.com/en/products/dam) and [case management](http://www.nuxeo.com/en/products/case-management). Designed by developers for developers, the Nuxeo platform offers a modern architecture, a powerful plug-in model and extensive packaging capabilities for building content applications.

More information on: <http://www.nuxeo.com/>
