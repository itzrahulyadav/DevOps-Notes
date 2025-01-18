#  CloudFront

- It is a CDN
- comprises of Edge locations,Regional caches
- Full documentation [Cloudfront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/IntroductionUseCases.html)

### LambdaEdge
- Lambdaedge are lambda  functions that override the behaviour of requests and responses
- Only support Python and Node.js
- Deployed at regional edge caches


### Cloudfront functions
- These are lightweight edge functions for high-scale,latency sensitive cdn customizatinos
- These are cheaper,faster but limited that lambda@edge
- Functions are deployed at edge locations


### Origin
- It's the source where cloudfront will send reqeuests
  
### Origin groups
- It allows you to group a primary and secondary origin together as a destination for requests enabling high availability and fault tolerance
- It includes two origins:
  - Primary origin : Where requests will be send
  - Secondary origin : a failover origin that will recieve traffic over the primary origin if the failover criteria is meet
 
- Failover criteria is based on http status codes i'e 400 or 500
- Only GET,HEAD and OPTIONS requests will make cloudfront failover and not other http methods


### Caching policy
- It is used to determine the cache key
- AWS has managed caching policy
- We can also create custom caching policy

### Origin request policy
- It is when a cache is missed and cloudfront should reach to origin to retrive data
- It's used to retrive additional information and maintain a good cache policy
- Learn [more](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/controlling-origin-requests.html)

### Resoponse header policy
- It modifies the http header in the response that the viewers will see

### Origin access identity
- It's a legacy method to ensure that an s3 bucket  is only accessed through the cloudfront and not directly via the internet
- It works by creating a cloudfront user that would be granted access via the s3 bucket policy

### Origin access control
- It is to ensure that an s3 bucket is only accessed through the cloudfront and not directly via the internet
- Uses IAM principal to authenticate with the s3 origins via the s3 bucket policy
- Protect against the deputy problem attacks
- can use SSE-KMS
- uses signature version 4 and allow access from all the regions

### Cloudfront origin shield
- Additional layer in the caching infra to minimize origin's load and improve it's cost

### Geographic restrictions
- This prevent users from specific geographic locatoins from accessing cloud front content
- Stutus code 403 is returned

  
### Caching query string parameters
- A query string is a part of the URL that assigns values to specific parameters that can be parsed by the web application and web browsers.
- Cloudfront can forward query string to origin (Origin request policy)
- Cloudfront cache key can be based off query parameters (cache policy)

### caching Cookie-based content 
- A cookie is a key-value based data sent from the website and is stored in the user's computer by the user's web browser while the user is browsing
- The Set-cookie headers contains the cookie data
- Cloudfront can forward cookies to an origin (Origin request policy)
- Cloudfront cache key can be based on cookies (Cache policy)


### Cloudfront content types
- Cloudfront servers don't determine the MIME type for the objects they serve
- MIME type indicates the nature and format of the document ,file etc.
- Web browsers use MIME type to determine how to process the url of a file
- It's recommended to set Content-Type header when uploading files to the origin

### Cache invalidation
- Cache can be invalidated to refresh the content
- It's recommended to invalidate only the specific files , we can also use batch files to invalidate cache
```
 aws cloudfront create-invalidation --distribution-id dkjieinvkdpgd --invalidat
  ion-batch file://invalid.json

```
### Cache busting with digests
- Cache busting is a way to prevent browsers from caching your content
- Cache digest is a value that appended at the end of file with the intention of busting the cache

### Requiring https
- Cloudfront can be configured to require  that viewers use https so that the connections are encrypted

### Cloudfront - Signed URLs
- It allow users to access private content via temporarily signed URLs
- It can be canned or custom policy


### Custom-error pages
- We can set custom error pages when serving content and make users redirect to specific pages
