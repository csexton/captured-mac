// filetransfer.h - definition for file transfer class, which provides additional file transfer capability

#include <curl/curl.h>
#include <string>

class file_transfer
{
public:
	file_transfer();
	~file_transfer();
	
private:
	// don't allow this object to be copied...probably being lazy here, but i can think of a good reason to allow it
	file_transfer(const file_transfer&);
	file_transfer& operator=(const file_transfer&);

public:
	int send_with_sftp(const std::string& username, const std::string& password, const std::string& host, const std::string& targetdir, const std::string& srcfile);

private:
	CURL* handle;
	static unsigned int instance_count;
};
