lambom
======

lambom is a tool to configure servers based on chef-solo and berkshelf.

Description
-----------
Riyic is a server configuration service based on chef (http://riyic.com).

The lambom gem is a tool to apply chef configurations generated with the riyic service, or defined in a pair of plain text files :
 - a [json attributes file](http://docs.opscode.com/chef_solo.html#attributes) where the server configuration is detailed
 - and a [berkshelf](http://github.com/berkshelf/berkshelf) file which specifies cookbooks restrictions and sources

Usage
-----
```
Usage: lambom [options]
    -A, --api [API ENDPOINT URL]     RIYIC Api endpoint to connect to download the server configuration
    -j, --json [JSON FILE]           Run server convergence with configuration from json attributes file
    -b, --berksfile [BERKSFILE FILE] Use specified berksfile to download cookbooks and dependencies
    -c, --cached                     Use local cached cookbooks
    -D, --download [TARBALL URL]     Download cookbooks tarball from url and unpack it in cookbooks chef path
    -e, --env [ENVIRONMENT]          Select environment
    -s, --server [SERVER_UUID]       Sets the server uuid to which to download configuration from RIYIC api
    -k, --keyfile [PRIVATE KEYFILE]  PEM Private keyfile to sign api requests
    -l, --loglevel [LOG_LEVEL]       Set loglevel
    -d, --debug                      Debug mode
    -v, --version                    Show version
```

Requirements
------------
- Tested in Ubuntu-12.04
- ruby 1.9.3
- chef ~> 11.8.2
- berkshelf ~> 2.0.12
- git
