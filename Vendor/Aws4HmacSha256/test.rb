require 'openssl'
def hexEncode bindata
  result=""
  data=bindata.unpack("C*")
  data.each {|b| result+= "%02x" % b}
  result
end
def getSignatureKey key, dateStamp, regionName, serviceName
    kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
    puts hexEncode(kDate)
    kRegion  = OpenSSL::HMAC.digest('sha256', kDate, regionName)
    puts hexEncode(kRegion)
    kService = OpenSSL::HMAC.digest('sha256', kRegion, serviceName)
    puts hexEncode(kService)
    kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")
    puts hexEncode(kSigning)

    kSigning
end

key = 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY'
dateStamp = '20120215'
regionName = 'us-east-1'
serviceName = 'iam'

getSignatureKey key, dateStamp, regionName, serviceName
