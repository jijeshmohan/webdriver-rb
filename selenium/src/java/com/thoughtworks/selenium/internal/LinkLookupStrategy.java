package com.thoughtworks.selenium.internal;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.thoughtworks.selenium.SeleniumException;
import com.thoughtworks.webdriver.WebDriver;
import com.thoughtworks.webdriver.WebElement;

public class LinkLookupStrategy implements LookupStrategy {
	private static final Pattern TEXT_MATCHING_STRATEGY_AND_VALUE_PATTERN = Pattern.compile("^(\\p{Alpha}+):(.*)");
	private Map textMatchingStrategies = new HashMap();

	public LinkLookupStrategy() {
		textMatchingStrategies.put("implicit", new GlobTextMatchingStrategy());
		textMatchingStrategies.put("glob", new GlobTextMatchingStrategy());
		textMatchingStrategies.put("regexp", new RegExTextMatchingStrategy());
		textMatchingStrategies.put("exact", new ExactTextMatchingStrategy());
	}
	
	public WebElement find(WebDriver driver, String use) {
		List elements = driver.selectElements("//a");
		
		String strategyName = "implicit";
		Matcher matcher = TEXT_MATCHING_STRATEGY_AND_VALUE_PATTERN.matcher(use);
		if (matcher.matches()) {
			strategyName = matcher.group(1);
			use = matcher.group(2);
		}
		TextMatchingStrategy strategy = (TextMatchingStrategy) textMatchingStrategies.get(strategyName);

		Iterator allLinks = elements.iterator();
		while (allLinks.hasNext()) {
			WebElement link = (WebElement) allLinks.next();
			if (!(strategy.isAMatch(use, link.getText())))
				allLinks.remove();
		}
		
		if (elements.size() > 0)
			return (WebElement) elements.get(0);
		throw new SeleniumException(use + " not found");
	}
}
