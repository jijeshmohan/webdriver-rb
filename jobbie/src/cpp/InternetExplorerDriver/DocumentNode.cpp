#include "stdafx.h"
#include "DocumentNode.h"
#include "ElementNode.h"

#include <iostream>
using namespace std;

DocumentNode::DocumentNode(IHTMLDocument2* doc)
{
	this->doc = doc;
	doc->AddRef();
}

DocumentNode::~DocumentNode()
{
	doc->Release();
}

Node* DocumentNode::getDocument()
{
	return new DocumentNode(doc);
}

Node* DocumentNode::getNextSibling()
{
	return NULL;
}

Node* DocumentNode::getFirstChild() 
{
	IHTMLDocument3* doc3;
	doc->QueryInterface(__uuidof(IHTMLDocument3), (void**)&doc3);

	IHTMLElement* rootElement;
	doc3->get_documentElement(&rootElement);
	doc3->Release();

	IHTMLDOMNode* rootNode;
	rootElement->QueryInterface(__uuidof(IHTMLDOMNode), (void**)&rootNode);
	rootElement->Release();

	ElementNode* toReturn = new ElementNode(rootNode);
	rootNode->Release();

	return toReturn;
}

Node* DocumentNode::getFirstAttribute() 
{
	return NULL;
}

const wchar_t* DocumentNode::name()
{
	wchar_t* toReturn = new wchar_t[16];
	wcscpy_s(toReturn, 16, L"<document node>");
	return toReturn;
}

const wchar_t* DocumentNode::getText()
{
	return NULL;
}
