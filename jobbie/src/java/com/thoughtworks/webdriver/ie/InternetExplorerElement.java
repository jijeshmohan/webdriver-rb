package com.thoughtworks.webdriver.ie;

import java.util.ArrayList;
import java.util.List;

import com.thoughtworks.webdriver.WebDriver;
import com.thoughtworks.webdriver.WebElement;

public class InternetExplorerElement implements WebElement {
	private long nodePointer;

	// Called from native code
	private InternetExplorerElement(long nodePointer) {
		this.nodePointer = nodePointer;
	}

	protected static native InternetExplorerElement createInternetExplorerElement(long ieWrapper, ElementNode node);
	
	public native WebDriver click();

	public native String getAttribute(String name);

	public List getChildrenOfType(String tagName) {
		List toReturn = new ArrayList();
		getChildrenOfTypeNatively(toReturn, tagName);
		return toReturn;
	}

	public native String getText();

	public native String getValue();

	public native WebDriver setValue(String value);
	
	public native boolean isEnabled();

	public native boolean isSelected();

	public native WebDriver setSelected();

	public native WebDriver submit();

	public native boolean toggle();

	protected void finalize() throws Throwable {
		deleteStoredObject();
	}
	
	private native void deleteStoredObject();

	private native void getChildrenOfTypeNatively(List toReturn, String tagName);
}
