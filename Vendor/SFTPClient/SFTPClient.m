//
//  SFTPUploader.m
//  Captured for Mac
//
//  Created by Jorge Velázquez on 3/11/11.
//  Copyright 2011 Codeography. All rights reserved.
//

#import "SFTPClient.h"

@implementation SFTPClient

#pragma mark: New init method
- (id)initWithSettings:(NSDictionary*)dict {
  self = [super init];
  if (self) {
    self.password = dict[@"password"];
    self.host = dict[@"hostname"];
    self.username = dict[@"username"];
    self.publicKeyFile = dict[@"public_key_file"];
    self.privateKeyFile = dict[@"private_key_file"];
    self.keyPassword = dict[@"key_password"];
    self.publicURL = dict[@"public_url"];
    self.pathOnServer = dict[@"path_on_server"];
  }
  
  return self;
}

#pragma mark: Imported from Utilities

- (NSString *)createUniqueFilename:(NSInteger)numChars {
  static char alNum[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  static size_t CHAR_COUNT = 62;

  char buf[64];
  srand((unsigned int)time(NULL));
  for (int i = 0; i < numChars; i++) {
    buf[i] = alNum[rand() % CHAR_COUNT];
  }
  buf[numChars] = 0;
//  strcat(buf, ".png");
  return [NSString stringWithCString:buf
                            encoding:NSASCIIStringEncoding];
}

- (NSString *)removeAnyTrailingSlashes:(NSString *)str {
  if (str) {
    if ([str hasSuffix:@"/"]) {
      // Remove any trailing slashes that might screw up removal.
      return [str substringToIndex:[str length] - 1];
    }
  }
  return str;
}

#pragma mark: Legacy Methods from SFTPUploader

- (NSString *)formatPath:(NSString *)targetDir {
  NSString *url = @"";
  if (targetDir && [targetDir length] > 0) {
    switch ([targetDir characterAtIndex:0])
    {
      case '/':
        url = [url stringByAppendingFormat:@"%@/", targetDir];
        break;

      case '~':
        url = [url stringByAppendingFormat:@"/%@/", targetDir];
        break;

      default:
        url = [url stringByAppendingFormat:@"/~/%@/", targetDir];
        break;
    }
  } else {
    // Use the home directory
    url = [NSString stringWithFormat:@"%@/~/", url];
  }
  return url;
}

- (BOOL)uploadFile:(NSString *)sourceFile {
  self.success = NO;
  // generate a unique filename
  NSString *tempNum = [self createUniqueFilename:5];
  NSString *ext = [NSURL URLWithString:sourceFile].pathExtension;
  NSString *tempNam = [NSString stringWithFormat:@"%@.%@", tempNum, ext];

  // get host, username and target directory options from user preferences
  NSString *targetDir = [self removeAnyTrailingSlashes:self.pathOnServer];
  NSString *imageUrl = [self removeAnyTrailingSlashes:self.publicURL];

  // format the urls
  NSString *url = [NSString stringWithFormat:@"sftp://%@%@%@", self.host, [self formatPath:targetDir], tempNam];

  imageUrl = [NSString stringWithFormat:@"%@/%@", imageUrl, tempNam];

  // reset the handle
  CURL *handle = curl_easy_init();

  // capture messages in a user-friendly format
  char buf[CURL_ERROR_SIZE];
  curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);

  // set the types of authentication that we are going to allow
  curl_easy_setopt(handle, CURLOPT_SSH_AUTH_TYPES, CURLSSH_AUTH_PASSWORD | CURLSSH_AUTH_PUBLICKEY);

  // set the curl options
  curl_easy_setopt(handle, CURLOPT_URL, [url cStringUsingEncoding:NSASCIIStringEncoding]);
  curl_easy_setopt(handle, CURLOPT_USERNAME, [self.username cStringUsingEncoding:NSASCIIStringEncoding]);
  if (self.password) {
    curl_easy_setopt(handle, CURLOPT_PASSWORD, [self.password cStringUsingEncoding:NSASCIIStringEncoding]);
  }
  /*
  const char *pk = [[publicKeyFile stringByExpandingTildeInPath] cStringUsingEncoding:NSASCIIStringEncoding];
  if (pk) {
    NSLog(@"Using public key file %s", pk);
    curl_easy_setopt(handle, CURLOPT_SSH_PUBLIC_KEYFILE, pk);
  }
  pk = [[privateKeyFile stringByExpandingTildeInPath] cStringUsingEncoding:NSASCIIStringEncoding];
  if (pk) {
    NSLog(@"Using private key file %s", pk);
    curl_easy_setopt(handle, CURLOPT_SSH_PRIVATE_KEYFILE, pk);
  }
  if (keyPassword) {
    curl_easy_setopt(handle, CURLOPT_KEYPASSWD, [keyPassword cStringUsingEncoding:NSASCIIStringEncoding]);
  }
   */
  curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
  FILE *fp = fopen([sourceFile cStringUsingEncoding:NSASCIIStringEncoding], "rb");
  curl_easy_setopt(handle, CURLOPT_READDATA, fp);
  curl_easy_setopt(handle, CURLOPT_TIMEOUT, 30);

  // do the upload
  CURLcode rc = curl_easy_perform(handle);
  fclose(fp);
  curl_easy_cleanup(handle);
  if (rc == CURLE_OK) {
    self.uploadUrl = imageUrl;
    self.success = YES;
  }
  return self.success;
}

- (NSString *)testConnection {
  NSString *testResponse = nil;

  // set the url to just do an ls of the target dir
  NSString *url = [NSString stringWithFormat:@"sftp://%@%@", self.host, [self formatPath:self.pathOnServer]];

  // reset the curl handle
  CURL *handle = curl_easy_init();

  // capture messages in a user-friendly format
  char buf[CURL_ERROR_SIZE];
  curl_easy_setopt(handle, CURLOPT_ERRORBUFFER, buf);

  // set the types of authentication that we are going to allow
  curl_easy_setopt(handle, CURLOPT_SSH_AUTH_TYPES, CURLSSH_AUTH_PASSWORD | CURLSSH_AUTH_PUBLICKEY);

  curl_easy_setopt(handle, CURLOPT_URL, [url cStringUsingEncoding:NSASCIIStringEncoding]);
  curl_easy_setopt(handle, CURLOPT_USERNAME, [self.username cStringUsingEncoding:NSASCIIStringEncoding]);
  if (self.password) {
    curl_easy_setopt(handle, CURLOPT_PASSWORD, [self.password cStringUsingEncoding:NSASCIIStringEncoding]);
  }
  const char *pk = [[self.publicKeyFile stringByExpandingTildeInPath] cStringUsingEncoding:NSASCIIStringEncoding];
  if (pk) {
    curl_easy_setopt(handle, CURLOPT_SSH_PUBLIC_KEYFILE, pk);
  }
  pk = [[self.privateKeyFile stringByExpandingTildeInPath] cStringUsingEncoding:NSASCIIStringEncoding];
  if (pk) {
    curl_easy_setopt(handle, CURLOPT_SSH_PRIVATE_KEYFILE, pk);
  }
  if (self.keyPassword) {
    curl_easy_setopt(handle, CURLOPT_KEYPASSWD, [self.keyPassword cStringUsingEncoding:NSASCIIStringEncoding]);
  }
  curl_easy_setopt(handle, CURLOPT_TIMEOUT, 10);

  CURLcode rc = curl_easy_perform(handle);
  curl_easy_cleanup(handle);
  if (rc != CURLE_OK) {
    testResponse = [NSString stringWithFormat:@"Error: %s", buf];
  }
  return testResponse;
}

@end
