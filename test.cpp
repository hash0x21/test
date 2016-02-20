// ConsoleApplication1.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <iostream>
#include <Windows.h>
#include <VersionHelpers.h>
#include <winsock.h>
#pragma comment(lib, "ws2_32")


using namespace std;

void printOSVersion() 
{
	if (IsWindows10OrGreater())
	{
		cout << "Windows 10" << endl; 
	}
	else if (IsWindows8OrGreater())
	{
		cout << "Windows 8" << endl; 
	}
	else if (IsWindows7OrGreater())
	{
		cout << "Windows 7" << endl; 
	}
	else if (IsWindowsVistaOrGreater())
	{
		cout << "Windows Vista" << endl;
	}
	else if (IsWindowsXPOrGreater())
	{
		cout << "Windows XP" << endl;
	}
	else if (IsWindowsServer())
	{
		cout << "Windows Server" << endl; 
	}

}

int is64BitOS()
{
	wchar_t dirPath[4096]; 
	return GetSystemWow64Directory(dirPath, 4096);
}

void printIPAddrs()
{
	//The WSAStartup function initiates the use of the Windows Sockets DLL by a process. 
	//The WSAStartup function returns a pointer to the WSADATA structure in the lpWSAData parameter.

	/* WSAStartup has two main purposes.

	Firstly, it allows you to specify what version of WinSock you want to use (you are requesting 2.2 in your example). In the WSADATA that it populates, it will tell you what version it is offering you based on your request. It also fills in some other information which you are not required to look at if you aren't interested. You never have to submit this WSADATA struct to WinSock again, because it is used purely to give you feedback on your WSAStartup request.

	The second thing it does, is to set-up all the "behind the scenes stuff" that your app needs to use sockets. The WinSock DLL file is loaded into your process, and it has a whole lot of internal structures that need to be set-up for each process. These structures are hidden from you, but they are visible to each of the WinSock calls that you make.

	Because these structures need to be set-up for each process that uses WinSock, each process must call WSAStartup to initialise the structures within its own memory space, and WSACleanup to tear them down again, when it is finished using sockets.*/

	/*typedef struct hostent {
	char FAR      *h_name;
	char FAR  FAR **h_aliases;
	short         h_addrtype;
	short         h_length;
	char FAR  FAR **h_addr_list;
	} HOSTENT, *PHOSTENT, FAR *LPHOSTENT;
	*/

	/*struct in_addr {
	unsigned long s_addr;  // load with inet_aton()
	};*/
	WSAData wsaData; //The WSADATA structure contains information about the Windows Sockets implementation.

	if (WSAStartup(MAKEWORD(1, 1), &wsaData) == 0)
	{
		char hostName[128];
		int i = 0;
		if (gethostname(hostName, sizeof(hostName)) == 0)
		{
			struct hostent *host = gethostbyname(hostName);
			struct in_addr addr;

			if (host != NULL)
			{
				while (host->h_addr_list[i] != 0)
				{
					addr.s_addr = *(u_long *)host->h_addr_list[i];
					cout << "IPv4 Address: " << inet_ntoa(addr) << endl;
					++i;
				}

			}
		}

		WSACleanup();

	}
	else
	{
		cout << "WSA Initialization failed" << endl;
	}
}


int main()
{
	
	unsigned int blah = 100; 
	//wchar_t *test = new wchar_t[4096]; 
	wchar_t test[4096]; // wchar_t tes[4096] == wchar_t *test = new wchar_t[4096] 

	//cout  << GetSystemWow64Directory(test, 4096);
	//cout << test << endl;
	//cout << sizeof(wchar_t);
	//cout << sizeof(char);
	//wprintf(test);
	printOSVersion(); 
	if (is64BitOS() > 0)
	{
		cout << "Running on 64 bit Architecture" << endl;
	}
	printIPAddrs();
		
	//gethostname(hn, 128); 
	//cout << system("ipconfig");
	//cout << hn;

    return 0;
}

