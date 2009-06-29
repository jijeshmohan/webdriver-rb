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
import static org.hamcrest.Matchers.is;
import static org.openqa.selenium.Ignore.Driver.SAFARI;

public class MiscTest extends AbstractDriverTestCase {
    public void testShouldReportTheCurrentUrlCorrectly() {
        driver.get(simpleTestPage);
        assertThat(driver.getCurrentUrl(), equalTo(simpleTestPage));

        driver.get(javascriptPage);
        assertThat(driver.getCurrentUrl(), equalTo(javascriptPage));
    }

    @Ignore(SAFARI)
    public void testShouldReturnTheSourceOfAPage() {
        driver.get(simpleTestPage);

        String source = driver.getPageSource().toLowerCase();
        
        assertThat(source.contains("<html"), is(true));
        assertThat(source.contains("</html"), is(true));
        assertThat(source.contains("an inline element"), is(true));
        assertThat(source.contains("<p id="), is(true));
        assertThat(source.contains("lotsofspaces"), is(true));
    }

    @NeedsFreshDriver
    @NoDriverAfterTest
    @Ignore(SAFARI)
    public void testShouldReturnAnEmptyStringIfTitleNotSet() {
      // We start on the default home page of the brower
      try {
        String title = driver.getTitle();
        assertEquals("", title);
      } catch (Exception e) {
        fail("Should not have thrown an exception: " + e.getMessage());
      } finally {
        driver.quit();
      }
    }
}
