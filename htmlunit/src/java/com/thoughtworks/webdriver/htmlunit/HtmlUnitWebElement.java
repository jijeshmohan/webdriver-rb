/*
 * Copyright 2007 ThoughtWorks, Inc
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package com.thoughtworks.webdriver.htmlunit;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.gargoylesoftware.htmlunit.html.ClickableElement;
import com.gargoylesoftware.htmlunit.html.DomNode;
import com.gargoylesoftware.htmlunit.html.DomText;
import com.gargoylesoftware.htmlunit.html.HtmlCheckBoxInput;
import com.gargoylesoftware.htmlunit.html.HtmlElement;
import com.gargoylesoftware.htmlunit.html.HtmlForm;
import com.gargoylesoftware.htmlunit.html.HtmlImageInput;
import com.gargoylesoftware.htmlunit.html.HtmlInput;
import com.gargoylesoftware.htmlunit.html.HtmlOption;
import com.gargoylesoftware.htmlunit.html.HtmlPreformattedText;
import com.gargoylesoftware.htmlunit.html.HtmlSelect;
import com.gargoylesoftware.htmlunit.html.HtmlSubmitInput;
import com.gargoylesoftware.htmlunit.html.HtmlTextArea;
import com.thoughtworks.webdriver.NoSuchElementException;
import com.thoughtworks.webdriver.WebElement;

public class HtmlUnitWebElement implements WebElement {
	private final HtmlElement element;
	private final static char nbspChar = (char) 160;
	private final static String[] blockLevelsTagNames = 
		{ "p", "h1", "h2", "h3", "h4", "h5", "h6", "dl", "div", "noscript", 
		  "blockquote", "form", "hr", "table", "fieldset", "address", "ul", "ol", "pre", "br" };
	
	public HtmlUnitWebElement(HtmlElement element) {
		this.element = element;
	}
	
	public void click() {
		if (!(element instanceof ClickableElement))
			return;
		
		ClickableElement clickableElement = ((ClickableElement) element);
		try {
			clickableElement.click();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}
	
	public void submit() {
		try {
			if (element instanceof HtmlForm) {
				((HtmlForm) element).submit();
				return;
			} else if (element instanceof HtmlSubmitInput) {
				((HtmlSubmitInput) element).click();
				return;
			} else if (element instanceof HtmlImageInput) {
				((HtmlImageInput) element).click();
				return;
			} else if (element instanceof HtmlInput) {
				((HtmlInput) element).getEnclosingForm().submit();
				return;
			}
			
			HtmlForm form = findParentForm();
			if (form == null) 
				throw new NoSuchElementException("Unable to find the containing form");
			form.submit();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}
	
	public String getValue() {
        if (element instanceof HtmlTextArea)
            return ((HtmlTextArea)element).getText();
        return getAttribute("value");
	}
	
	public void setValue(String value) {
		if (element instanceof HtmlInput)
			element.setAttributeValue("value", value);
        else if (element instanceof HtmlTextArea)
            ((HtmlTextArea)element).setText(value);
        else
			throw new UnsupportedOperationException("You may only set the value of elements that are input elements");
	}
	
	public String getAttribute(String name) {
		final String lowerName = name.toLowerCase();

		String value = element.getAttributeValue(name);

		if ("disabled".equals(lowerName)) {
			return isEnabled() ? "false" : "true";
		}
		if ("selected".equals(lowerName)) {
			return (value.equalsIgnoreCase("selected") ? "true" : "false");
		}
		if ("checked".equals(lowerName)) {
			return (value.equalsIgnoreCase("checked") ? "true" : "false");
		}

		if (!"".equals(value))
			return value;
		
		if (element.isAttributeDefined(name))
			return "";
		
		
		return null;
	}

	public boolean toggle() {
		try {
			if (element instanceof HtmlCheckBoxInput) {
				((HtmlCheckBoxInput) element).click();
				return isSelected();
			}
			
			if (element instanceof HtmlOption) {
				HtmlOption option = (HtmlOption) element;
				HtmlSelect select = option.getEnclosingSelect();
				if (select.isMultipleSelectEnabled()) {
					option.setSelected(!option.isSelected());
					return isSelected();
				}
			}
			
			throw new UnsupportedOperationException("You may only toggle checkboxes or options in a select which allows multiple selections");
		} catch (IOException e) {
			throw new RuntimeException("Unexpected exception: " + e);
		}
	}
	
	public boolean isSelected() {
		if (element instanceof HtmlInput) 
			return ((HtmlInput) element).isChecked();
		else if (element instanceof HtmlOption)
			return ((HtmlOption) element).isSelected();
		
		throw new UnsupportedOperationException("Unable to determine if element is selected. Tag name is: " + element.getTagName());
	}
	
	public void setSelected() {
		String disabledValue = element.getAttributeValue("disabled");
		if (disabledValue.length() > 0) {
			throw new UnsupportedOperationException("You may not select a disabled element");
		}
		
		if (element instanceof HtmlInput) 
			((HtmlInput) element).setChecked(true);
		else if (element instanceof HtmlOption)
			((HtmlOption) element).setSelected(true);
		else
			throw new UnsupportedOperationException("Unable to select element. Tag name is: " + element.getTagName());
	}
	
	public boolean isEnabled() {
		if (element instanceof HtmlInput) 
			return !((HtmlInput) element).isDisabled();
		
		if (element instanceof HtmlTextArea)
			return !((HtmlTextArea) element).isDisabled();
		
		return true;
	}

	// This isn't very pretty. Sorry.
	public String getText() {
		StringBuffer toReturn = new StringBuffer();
		StringBuffer textSoFar = new StringBuffer();
		
		getTextFromNode(element, toReturn, textSoFar, element instanceof HtmlPreformattedText);
		
		String text = collapseWhitespace(textSoFar) + toReturn.toString();
		
		int index = text.length();
		int lastChar = ' ';
		while (isWhiteSpace(lastChar)) {
			index--;
			lastChar = text.charAt(index);
		}
		
		return text.substring(0, index+1);
	}

	private boolean isWhiteSpace(int lastChar) {
		return lastChar == '\n' || lastChar == ' ' || lastChar == '\t' || lastChar == '\r';
	}

	private void getTextFromNode(DomNode node, StringBuffer toReturn, StringBuffer textSoFar, boolean isPreformatted) {
		if (isPreformatted) {
			getPreformattedText(node, toReturn);
		}
		
		Iterator children = node.getChildIterator();
		while (children.hasNext()) {
			DomNode child = (DomNode) children.next();
			
			// Do we need to collapse the text so far?
			if (child instanceof HtmlPreformattedText) {
				toReturn.append(collapseWhitespace(textSoFar));
				textSoFar.delete(0, textSoFar.length());
				getTextFromNode(child, toReturn, textSoFar, true);
				continue;
			}

			// Or is this just plain text?
			if (child instanceof DomText) {
				String textToAdd = ((DomText) child).getData();
				textToAdd = textToAdd.replace(nbspChar, ' ');
				textSoFar.append(textToAdd);
				continue;
			}
			
			// Treat as another child node. 
			getTextFromNode(child, toReturn, textSoFar, false);
		}
		
		if (isBlockLevel(node)) {
			toReturn.append(collapseWhitespace(textSoFar)).append("\n");
			textSoFar.delete(0, textSoFar.length());
		}
	}

	private boolean isBlockLevel(DomNode node) {
		// From the HTML spec (http://www.w3.org/TR/html401/sgml/dtd.html#block)
//		 <!ENTITY % block "P | %heading; | %list; | %preformatted; | DL | DIV | NOSCRIPT | BLOCKQUOTE | FORM | HR | TABLE | FIELDSET | ADDRESS">
//	     <!ENTITY % heading "H1|H2|H3|H4|H5|H6">
//	     <!ENTITY % list "UL | OL">
//	     <!ENTITY % preformatted "PRE">

		if (!(node instanceof HtmlElement))
			return false;
		
		String tagName = ((HtmlElement) node).getTagName().toLowerCase();
		for (int i = 0; i < blockLevelsTagNames.length; i++) {
			if (blockLevelsTagNames[i].equals(tagName))
				return true;
		}
		return false;
	}

	private String collapseWhitespace(StringBuffer textSoFar) {
		String textToAdd = textSoFar.toString();
		return textToAdd.replaceAll("\\p{javaWhitespace}+", " ").replaceAll("\r", "");
	}

	private void getPreformattedText(DomNode node, StringBuffer toReturn) {
		String xmlText = node.asXml();
		toReturn.append(xmlText.replaceAll("^<pre.*?>", "").replaceAll("</pre.*>$", ""));
	}

	public List getChildrenOfType(String tagName) {
		 Iterator allChildren = element.getAllHtmlChildElements();
		 List elements = new ArrayList();
		 while (allChildren.hasNext()) {
			 HtmlElement child = (HtmlElement) allChildren.next();
			 if (tagName.equals(child.getTagName())) {
				 elements.add(new HtmlUnitWebElement(child));
			 }
		 }
		 return elements;
	}

    public boolean isDisplayed() {
        return false;
    }

    private HtmlForm findParentForm() {
		DomNode current = element;
		while (!(current == null || current instanceof HtmlForm)) {
			current = current.getParentNode();
		}
		return (HtmlForm) current;
	}
}
