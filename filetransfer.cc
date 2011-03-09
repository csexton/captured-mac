// filetransfer.cc - provides additional methods for transferring images

#include <sys/stat.h>
#include <libgen.h>

#include "filetransfer.h"

unsigned int file_transfer::instance_count = 0;

file_transfer::file_transfer()
: handle(NULL)
{
	if (instance_count++ == 0)
		curl_global_init(CURL_GLOBAL_ALL);
	handle = curl_easy_init();
}

file_transfer::~file_transfer()
{
	curl_easy_cleanup(handle);
	if (--instance_count == 0)
		curl_global_cleanup();
}

int file_transfer::send_file(protocol proto, const std::string& username, const std::string& password, const std::string& host, const std::string& targetdir, const std::string& srcfile)
{
	CURLcode rc = CURLE_OK;
	
	// make sure we have a valid handle
	if (handle == NULL)
		return -1;
	
	// make sure we can open the file
	FILE* fp = fopen(srcfile.c_str(), "rb");
	if (fp == NULL)
		return -2;
	
	// set username, if provided
	if (username.length() > 0)
	{
		rc = curl_easy_setopt(handle, CURLOPT_USERNAME, username.c_str());
		if (rc != CURLE_OK)
		{
			fclose(fp);
			return rc;
		}
	}
	
	// set password, if provided
	if (password.length() > 0)
	{
		rc = curl_easy_setopt(handle, CURLOPT_PASSWORD, password.c_str());
		if (rc != CURLE_OK)
		{
			fclose(fp);
			return rc;
		}
	}
	
	// set the host
	std::string url;
	if (proto == protocol_scp)
		url.assign("scp://");
	else if (proto == protocol_sftp)
		url.assign("sftp://");
	else
	{
		// should never happen, since we're using enumerated type
		fclose(fp);
		return -3;
	}
	url += host + "/";
	if (targetdir.length() == 0)
		url += "~/";
	else
		url += targetdir + "/";
	url.append("uniquefilenamehere"); // TODO: create unique filename
	rc = curl_easy_setopt(handle, CURLOPT_URL, url.c_str());
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}
	
	// tell libcurl we're doing an upload
	rc = curl_easy_setopt(handle, CURLOPT_UPLOAD, 1);
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}

	// stat the file, we'll need the file size for the request
	struct stat st;
	if (stat(srcfile.c_str(), &st) != 0)
	{
		fclose(fp);
		return -4;
	}
	
	// now set the file size for the request
	rc = curl_easy_setopt(handle, CURLOPT_INFILESIZE, st.st_size);
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}

	// give libcurl the file pointer so it can manage the upload
	rc = curl_easy_setopt(handle, CURLOPT_READDATA, fp);
	if (rc != CURLE_OK)
	{
		fclose(fp);
		return rc;
	}
	
	// do the file transfer
	rc = curl_easy_perform(handle);
	
	// close the file
	fclose(fp);
	
	return rc;
}
