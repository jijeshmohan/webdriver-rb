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

import static org.openqa.selenium.Ignore.Driver.FIREFOX;
import static org.openqa.selenium.Ignore.Driver.HTMLUNIT;
import static org.openqa.selenium.Ignore.Driver.IE;
import static org.openqa.selenium.Ignore.Driver.REMOTE;


public class I18nTest extends AbstractDriverTestCase {

  /**
   * The Hebrew word shalom (peace) encoded in order Shin (sh) Lamed (L) Vav (O) final-Mem (M).
   */
  private static final String shalom = "\u05E9\u05DC\u05D5\u05DD";


  /**
   * The Hebrew word tmunot (images) encoded in order Taf (t) Mem (m) Vav (u) Nun (n) Vav (o) Taf
   * (t).
   */
  private static final String tmunot = "\u05EA\u05DE\u05D5\u05E0\u05D5\u05EA";

  @Ignore({HTMLUNIT, IE, FIREFOX})
  public void testCn() {
    driver.get(chinesePage);
    driver.findElement(By.linkText(Messages.getString("I18nTest.link1"))).click();
  }

  @Ignore(REMOTE)
  public void testEnteringHebrewTextFromLeftToRight() {
    driver.get(chinesePage);
    WebElement input = driver.findElement(By.name("i18n"));

    input.sendKeys(shalom);

    assertEquals(shalom, input.getValue());
  }

  @Ignore(REMOTE)
  public void testEnteringHebrewTextFromRightToLeft() {
    driver.get(chinesePage);
    WebElement input = driver.findElement(By.name("i18n"));

    input.sendKeys(tmunot);

    assertEquals(tmunot, input.getValue());
  }
}
