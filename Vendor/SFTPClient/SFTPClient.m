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
    self.host =dict[@"host"];
    self.username =dict[@"username"];
    self.targetDir =dict[@"target_dir"];
    self.publicKeyFile =dict[@"public_key_file"];
    self.privateKeyFile =dict[@"private_key_file"];
    self.keyPassword = dict[@"key_password"];


    return self;
  }
  
  return nil;
}

#pragma mark: Imported from Utilities

- (NSString *)createUniqueFilename:(NSInteger)numChars {
  static char alNum[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  static size_t CHAR_COUNT = 62;
  static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

  char buf[64];
  srand((unsigned int)time(NULL));
  for (int i = 0; i < numChars; i++) {
    buf[i] = alNum[rand() % CHAR_COUNT];
  }
  buf[numChars] = 0;
  strcat(buf, ".png");
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
  NSString *tempNam = [self createUniqueFilename:5];

  // get host, username and target directory options from user preferences
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *host = [defaults stringForKey:@"SFTPHost"];
  NSString *username = [defaults stringForKey:@"SFTPUser"];
  NSString *targetDir = [self removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPPath"]];
  NSString *imageUrl = [self removeAnyTrailingSlashes:[defaults stringForKey:@"SFTPURL"]];
  NSString *publicKeyFile = [defaults stringForKey:@"SFTPPublicKeyFile"];
  NSString *privateKeyFile = [defaults stringForKey:@"SFTPPrivateKeyFile"];
  NSString *keyPassword = [defaults stringForKey:@"SFTPKeyPassword"];

  // format the urls
  NSString *url = [NSString stringWithFormat:@"sftp://%@%@%@", host, [self formatPath:targetDir], tempNam];

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
  curl_easy_setopt(handle, CURLOPT_USERNAME, [username cStringUsingEncoding:NSASCIIStringEncoding]);
  if (self.password) {
    curl_easy_setopt(handle, CURLOPT_PASSWORD, [self.password cStringUsingEncoding:NSASCIIStringEncoding]);
  }
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
  curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
  FILE *fp = fopen([sourceFile cStringUsingEncoding:NSASCIIStringEncoding], "rb");
  curl_easy_setopt(handle, CURLOPT_READDATA, fp);
  curl_easy_setopt(handle, CURLOPT_TIMEOUT, 30);

  // do the upload
  CURLcode rc = curl_easy_perform(handle);
  fclose(fp);
  curl_easy_cleanup(handle);
  if (rc == CURLE_OK) {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"SFTP", @"Type",
                          imageUrl, @"ImageURL",
                          @"", @"DeleteImageURL",
                          sourceFile, @"FilePath",
                          nil];
    self.uploadUrl = imageUrl;
    self.success = YES;

  } else {
  }
  return self.success;
}

- (NSString *)testConnection {
  NSString *testResponse = nil;

  // set the url to just do an ls of the target dir
  NSString *url = [NSString stringWithFormat:@"sftp://%@%@", self.host, [self formatPath:self.targetDir]];

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
