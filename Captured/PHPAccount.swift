//
//  PHPAccount.swift
//  Captured
//
//  Created by Christopher Sexton on 2/8/16.
//  Copyright © 2016 Christopher Sexton. All rights reserved.
//

import Foundation

class PHPAccount: Account {

  enum SecretKeys: String {
    case APIToken = "api_token"
    case EndpointURL = "endpoint_url"
  }

  override func accountType() -> String {
    return "Captured PHP"
  }

  dynamic var apiToken: String? {
    get { return self.secrets[SecretKeys.APIToken.rawValue] }
    set { self.secrets[SecretKeys.APIToken.rawValue] = newValue }
  }

  dynamic var endpointURL: String? {
    get { return self.secrets[SecretKeys.EndpointURL.rawValue] }
    set { self.secrets[SecretKeys.EndpointURL.rawValue] = newValue }
  }

}