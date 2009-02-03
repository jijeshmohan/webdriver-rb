/*
Copyright 2007-2009 WebDriver committers
Copyright 2007-2009 Google Inc.
Portions copyright 2007 ThoughtWorks, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include "stdafx.h"

#include <ctime>

#include "utils.h"
#include "logging.h"

using namespace std;

safeIO gSafe;

void throwException(JNIEnv *env, const char* className, const char *message)
{
	jclass newExcCls;
	env->ExceptionDescribe();
	env->ExceptionClear();
	newExcCls = env->FindClass(className);
	if (newExcCls == NULL) {
		return;
	}
	env->ThrowNew(newExcCls, message);
}

void throwException(JNIEnv *env, const char* className, LPCWSTR msg)
{
	std::string str;
	cw2string(msg, str);
	throwException(env, className, str.c_str());
}

void throwNoSuchElementException(JNIEnv *env, LPCWSTR msg)
{
	throwException(env, "org/openqa/selenium/NoSuchElementException", msg);
}

void throwNoSuchFrameException(JNIEnv *env, LPCWSTR msg)
{
	throwException(env, "org/openqa/selenium/NoSuchFrameException", msg);
}

void throwRunTimeException(JNIEnv *env, LPCWSTR msg)
{
	throwException(env, "org/openqa/selenium/WebDriverException", msg);
}

void throwUnsupportedOperationException(JNIEnv *env, LPCWSTR msg)
{
	throwException(env, "java/lang/UnsupportedOperationException", msg);
}

jobject newJavaInternetExplorerDriver(JNIEnv* env, InternetExplorerDriver* driver) 
{
	jclass clazz = env->FindClass("org/openqa/selenium/ie/InternetExplorerDriver");
	jmethodID cId = env->GetMethodID(clazz, "<init>", "(J)V");

	return env->NewObject(clazz, cId, (jlong) driver);
}


void wait(long millis)
{
	clock_t end = clock() + millis;
	do {
        MSG msg;
		if (PeekMessage( &msg, NULL, 0, 0, PM_REMOVE)) {
			TranslateMessage(&msg); 
			DispatchMessage(&msg); 
		}
		Sleep(0);
	} while (clock() < end);
}

void waitWithoutMsgPump(long millis)
{
	Sleep(millis);
}

// "Internet Explorer_Server" + 1
#define LONGEST_NAME 25

HWND getChildWindow(HWND hwnd, LPCTSTR name)
{
	TCHAR pszClassName[LONGEST_NAME];
	HWND hwndtmp = GetWindow(hwnd, GW_CHILD);
	while (hwndtmp != NULL) {
		::GetClassName(hwndtmp, pszClassName, LONGEST_NAME);
		if (lstrcmp(pszClassName, name) == 0) {
			return hwndtmp;
		}
		hwndtmp = GetWindow(hwndtmp, GW_HWNDNEXT);
	}
	return NULL;
}

LPCWSTR comvariant2cw(CComVariant& toConvert) 
{
	VARTYPE type = toConvert.vt;

	switch(type) {
		case VT_BOOL:
			return toConvert.boolVal == VARIANT_TRUE ? 	L"true":L"false";

		case VT_BSTR:
			return bstr2cw(toConvert.bstrVal);

		case VT_EMPTY:
			return L"";

		case VT_NULL:
			// TODO(shs96c): This should really return NULL.
			return L"";

		// This is lame
		case VT_DISPATCH:
			return L"";
	}
	return L"";
}


LPCWSTR combstr2cw(CComBSTR& from) 
{
	if (!from.operator BSTR()) {
		return L"";
	}

	return (LPCWSTR) from.operator BSTR();
}

LPCWSTR bstr2cw(BSTR& from) 
{
	if (!from) {
		return L"";
	}

	return (LPCWSTR) from;
}

jstring lpcw2jstring(JNIEnv *env, LPCWSTR text, int size)
{
	SCOPETRACER
	if (!text)
		return NULL;

	return env->NewString((const jchar*) text, 
		(jsize) ((size==-1) ? wcslen(text):size) );
}


long getLengthOf(SAFEARRAY* ary)
{
	if (!ary)
		return 0;

	long lower = 0;
	SafeArrayGetLBound(ary, 1, &lower);
	long upper = 0;
	SafeArrayGetUBound(ary, 1, &upper);
	return 1 + upper - lower;
}

/*
bool on_catchAllExceptions()
{
	safeIO::CoutA("Exception caught in dll", true);
	// Do nothing for the moment.
	return true;
}
*/

safeIO::safeIO()
{
	m_cs_out.Init();
	// LOG::File("C:/tmp/test.log");
	LOG::Level("INFO");
}

void safeIO::CoutL(LPCWSTR str, bool showThread, int cc)
{
	std::string output_str;
	cw2string(str, output_str);

	safeIO::CoutA(output_str.c_str(), showThread, cc);
}

void safeIO::CoutA(LPCSTR str, bool showThread, int cc)
{
#ifdef __VERBOSING_DLL__
	gSafe.m_cs_out.Lock();
	if(showThread)
	{
		DWORD thrID = GetCurrentThreadId();
		if(cc>0)
		{
			LOG(INFO) << "[0x" << hex << thrID << "] "  << " (" << cc << ") " << str;
		}
		else if(cc<0)
		{
			LOG(INFO) << "[0x" << hex << thrID << "] "  << " (" << (-cc) << ") " << str;
		}
		else
		{
			LOG(INFO) << "[0x" << hex << thrID << "] "  << str;
		}
	}
	else
	{
		LOG(INFO) << str;
	}
	gSafe.m_cs_out.Unlock();
#endif
}

char* ConvertLPCWSTRToLPSTR (LPCWSTR lpwszStrIn)
{
  LPSTR pszOut = NULL;
  if (lpwszStrIn != NULL)
  {
	int nInputStrLen = (int) wcslen (lpwszStrIn);

	// Double NULL Termination
	int nOutputStrLen = WideCharToMultiByte (CP_ACP, 0, lpwszStrIn, nInputStrLen, NULL, 0, 0, 0) + 2;
	pszOut = new char [nOutputStrLen];

	if (pszOut)
	{
	  memset (pszOut, 0x00, nOutputStrLen);
	  WideCharToMultiByte(CP_ACP, 0, lpwszStrIn, nInputStrLen, pszOut, nOutputStrLen, 0, 0);
	}
  }
  return pszOut;
}

inline void wstring2string(const std::wstring& inp, std::string &out)
{
	cw2string(inp.c_str(), out);
} 

void cw2string(LPCWSTR inp, std::string &out)
{
	LPSTR pszOut = ConvertLPCWSTRToLPSTR (inp);
	if(!pszOut)
	{
		out = "";
		return;
	}
	out = pszOut;
	delete [] pszOut;
} 
