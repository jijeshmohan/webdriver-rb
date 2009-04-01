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

#include "StdAfx.h"

#include "errorcodes.h"
#include "logging.h"
#include "utils.h"
#include "InternalCustomMessage.h"

using namespace std;

ElementWrapper::ElementWrapper(InternetExplorerDriver* ie, IHTMLElement *pElem)
	: pElement(pElem)
{
	this->ie = ie;
}


ElementWrapper::~ElementWrapper()
{
}

DataMarshaller& ElementWrapper::commandData()
{
	return ie->p_IEthread->getCmdData();
}

LPCWSTR ElementWrapper::getElementName()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETELEMENTNAME,)
	return data.output_string_.c_str();
}

LPCWSTR ElementWrapper::getAttribute(LPCWSTR name)
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETATTRIBUTE, name)
	return data.output_string_.c_str();
}

LPCWSTR ElementWrapper::getValue()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETVALUE,)
	return data.output_string_.c_str();
}


int ElementWrapper::sendKeys(LPCWSTR newValue)
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_SENDKEYS, newValue)
	int result = data.error_code;
	if (result != SUCCESS) {
		return result;
	}

	DataMarshaller& data2 = prepareCmData();
	sendThreadMsg(_WD_ELEM_BLUR, data2);

	return data2.error_code;
}

void ElementWrapper::clear()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_CLEAR,)
}

bool ElementWrapper::isSelected()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_ISSELECTED,)
	return data.output_bool_;
}

int ElementWrapper::setSelected()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_SETSELECTED,)
	return data.error_code;
}

bool ElementWrapper::isEnabled()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_ISENABLED,)
	return data.output_bool_;
}

bool ElementWrapper::isDisplayed()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_ISDISPLAYED,)
	return data.output_bool_;
}

int ElementWrapper::toggle()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_TOGGLE,)

	return data.error_code;
}

int ElementWrapper::getLocationWhenScrolledIntoView(HWND* hwnd, long* x, long* y) 
{
	SCOPETRACER
    SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETLOCATIONONCESCROLLEDINTOVIEW,)

    VARIANT result = data.output_variant_;
    
    if (result.vt != VT_ARRAY) {
            *hwnd = NULL;
            *x = 0;
            *y = 0;
			return -EUNHANDLEDERROR;
    }

    SAFEARRAY* ary = result.parray;
    long index = 0;
    CComVariant hwndVariant;
    SafeArrayGetElement(ary, &index, (void*) &hwndVariant);
    *hwnd = (HWND) hwndVariant.llVal;

    index = 1;
    CComVariant xVariant;
    SafeArrayGetElement(ary, &index, (void*) &xVariant);
    *x = xVariant.lVal;

    index = 2;
    CComVariant yVariant;
    SafeArrayGetElement(ary, &index, (void*) &yVariant);
    *y = yVariant.lVal;

    SafeArrayDestroy(ary);

	return SUCCESS;
}

void ElementWrapper::getLocation(long* x, long* y) 
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETLOCATION,)

	VARIANT result = data.output_variant_;
	
	if (result.vt != VT_ARRAY) {
		*x = 0;
		*y = 0;
		return;
	}

	SAFEARRAY* ary = result.parray;
	long index = 0;
	CComVariant xVariant;
	SafeArrayGetElement(ary, &index, (void*) &xVariant);
	*x = xVariant.lVal;

	CComVariant yVariant;
	index = 1;
	SafeArrayGetElement(ary, &index, (void*) &yVariant);
	*y = yVariant.lVal;

	SafeArrayDestroy(ary);
}

int ElementWrapper::getWidth(long* width)
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETWIDTH,)

	if (data.error_code != SUCCESS) return data.error_code;
	*width = data.output_long_;
	return SUCCESS;
}

int ElementWrapper::getHeight(long* height)
{
	SCOPETRACER

	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETHEIGHT,)
	if (data.error_code != SUCCESS) return data.error_code;
	*height = data.output_long_;
	return SUCCESS;
}

LPCWSTR ElementWrapper::getValueOfCssProperty(LPCWSTR propertyName)
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETVALUEOFCSSPROP, propertyName)
	return data.output_string_.c_str();
}

LPCWSTR ElementWrapper::getText()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETTEXT,)
	return data.output_string_.c_str();
}

int ElementWrapper::click()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_CLICK,)

	return data.error_code;
}

void ElementWrapper::submit()
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_SUBMIT,)
}


std::vector<ElementWrapper*>* ElementWrapper::getChildrenWithTagName(LPCWSTR tagName)
{
	SCOPETRACER
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_GETCHILDRENWTAGNAME, tagName)

	std::vector<IHTMLElement*> &allElems = data.output_list_html_element_;

	std::vector<ElementWrapper*> *toReturn = new std::vector<ElementWrapper*>();

	std::vector<IHTMLElement*>::const_iterator cur, end = allElems.end();
	for(cur = allElems.begin();cur < end; cur++)
	{
		IHTMLElement* elem = *cur;
		toReturn->push_back(new ElementWrapper(ie, elem));
	}
	return toReturn;


}

void ElementWrapper::releaseInterface()
{
	///// TODO !!!
	return;
	SEND_MESSAGE_WITH_MARSHALLED_DATA(_WD_ELEM_RELEASE,)
}

/////////////////////////////////////////////////////////////////////

DataMarshaller& ElementWrapper::prepareCmData()
{
	DataMarshaller& data = commandData();
	data.input_html_element_ = pElement;
	return data;
}

DataMarshaller& ElementWrapper::prepareCmData(LPCWSTR str)
{
	DataMarshaller& data = prepareCmData();
	data.input_string_ = str;
	return data;
}

bool ElementWrapper::sendThreadMsg(UINT msg, DataMarshaller& data)
{
	return ie->sendThreadMsg(msg, data);
}


