/*
Copyright 2007-2009 WebDriver committers
Copyright 2007-2009 Google Inc.

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

package org.openqa.selenium;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.openqa.selenium.Ignore.Driver.CHROME;
import static org.openqa.selenium.Ignore.Driver.IPHONE;
import static org.openqa.selenium.Ignore.Driver.SELENESE;

import java.util.List;

public class CorrectEventFiringTest extends AbstractDriverTestCase {

  @Ignore(value = CHROME, reason = "Webkit bug 22261")
  @JavascriptEnabled
  public void testShouldFireFocusEventWhenClicking() {
    driver.get(javascriptPage);

    clickOnElementWhichRecordsEvents();

    assertEventFired("focus");
  }

  @JavascriptEnabled
  public void testShouldFireClickEventWhenClicking() {
    driver.get(javascriptPage);

    clickOnElementWhichRecordsEvents();

    assertEventFired("click");
  }

  @JavascriptEnabled
  @Ignore(SELENESE)
  public void testShouldFireMouseDownEventWhenClicking() {
    driver.get(javascriptPage);

    clickOnElementWhichRecordsEvents();

    assertEventFired("mousedown");
  }

  @JavascriptEnabled
  @Ignore(SELENESE)
  public void testShouldFireMouseUpEventWhenClicking() {
    driver.get(javascriptPage);

    clickOnElementWhichRecordsEvents();

    assertEventFired("mouseup");
  }

  @Ignore(value = {CHROME, SELENESE}, reason = "Webkit bug 22261")
  @JavascriptEnabled
  public void testShouldFireEventsInTheRightOrder() {
    driver.get(javascriptPage);

    clickOnElementWhichRecordsEvents();

    String text = driver.findElement(By.id("result")).getText();

    int lastIndex = -1;
    for (String event : new String[]{"mousedown", "focus", "mouseup", "click"}) {
      int index = text.indexOf(event);

      assertTrue(event + " did not fire at all", index != -1);
      assertTrue(event + " did not fire in the correct order", index > lastIndex);
    }
  }

  @JavascriptEnabled
  @Ignore(SELENESE)
  public void testsShouldIssueMouseDownEvents() {
    driver.get(javascriptPage);
    driver.findElement(By.id("mousedown")).click();

    String result = driver.findElement(By.id("result")).getText();
    assertThat(result, equalTo("mouse down"));
  }

  @JavascriptEnabled
  public void testShouldIssueClickEvents() {
    driver.get(javascriptPage);
    driver.findElement(By.id("mouseclick")).click();

    String result = driver.findElement(By.id("result")).getText();
    assertThat(result, equalTo("mouse click"));
  }

  @JavascriptEnabled
  @Ignore(SELENESE)
  public void testShouldIssueMouseUpEvents() {
    driver.get(javascriptPage);
    driver.findElement(By.id("mouseup")).click();

    String result = driver.findElement(By.id("result")).getText();
    assertThat(result, equalTo("mouse up"));
  }

  @JavascriptEnabled
  @Ignore({IPHONE, SELENESE})
  public void testMouseEventsShouldBubbleUpToContainingElements() {
    driver.get(javascriptPage);
    driver.findElement(By.id("child")).click();

    String result = driver.findElement(By.id("result")).getText();
    assertThat(result, equalTo("mouse down"));
  }

  @JavascriptEnabled
  @Ignore({IPHONE, SELENESE})
  public void testShouldEmitOnChangeEventsWhenSelectingElements() {
    driver.get(javascriptPage);
    WebElement select = driver.findElement(By.id("selector"));
    List<WebElement> allOptions = select.findElements(By.tagName("option"));

    String initialTextValue = driver.findElement(By.id("result")).getText();

    WebElement foo = allOptions.get(0);
    WebElement bar = allOptions.get(1);

    foo.setSelected();
    assertThat(driver.findElement(By.id("result")).getText(),
               equalTo(initialTextValue));
    bar.setSelected();
    assertThat(driver.findElement(By.id("result")).getText(),
               equalTo("bar"));
  }

  @JavascriptEnabled
  @Ignore(SELENESE)
  public void testShouldEmitOnChangeEventsWhenChangingTheStateOfACheckbox() {
    driver.get(javascriptPage);
    WebElement checkbox = driver.findElement(By.id("checkbox"));

    checkbox.setSelected();
    assertThat(driver.findElement(By.id("result")).getText(),
               equalTo("checkbox thing"));
  }

  @JavascriptEnabled
  public void testShouldEmitClickEventWhenClickingOnATextInputElement() {
    driver.get(javascriptPage);

    WebElement clicker = driver.findElement(By.id("clickField"));
    clicker.click();

    assertThat(clicker.getValue(), equalTo("Clicked"));
  }

  @JavascriptEnabled
  public void testClearingAnElementShouldCauseTheOnChangeHandlerToFire() {
    driver.get(javascriptPage);

    WebElement element = driver.findElement(By.id("clearMe"));
    element.clear();

    WebElement result = driver.findElement(By.id("result"));
    assertThat(result.getText(), equalTo("Cleared"));
  }

  private void clickOnElementWhichRecordsEvents() {
    driver.findElement(By.id("plainButton")).click();
  }

  private void assertEventFired(String eventName) {
    WebElement result = driver.findElement(By.id("result"));
    String text = result.getText();
    assertTrue("No " + eventName + " fired", text.contains(eventName));
  }
}
