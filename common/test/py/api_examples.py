# Copyright 2008-2009 WebDriver committers
# Copyright 2008-2009 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/python

import datetime
import logging
import os
import re
import tempfile
import time
import shutil
import simplejson
import socket
import sys
import unittest
from wsgiref.handlers import format_date_time
from webdriver.common.exceptions import *
from webdriver.common.webserver import SimpleWebServer
import webdriver.remote.webdriver
import webdriver.common_tests
from webdriver.common_tests import utils

webserver = SimpleWebServer()
driver = None

def not_available_on_remote(func):
    def testMethod(self):
        if type(self.driver) == webdriver.remote.webdriver.WebDriver:
            return lambda x: None
        else:
            return func(self)
    return testMethod


class ApiExampleTest (unittest.TestCase):

    def setUp(self):
        self.driver = driver

    def tearDown(self):
        pass

    def testGetTitle(self):
        self._loadSimplePage()
        title = self.driver.get_title()
        self.assertEquals("Hello WebDriver", title)

    def testGetCurrentUrl(self):
        self._loadSimplePage()
        url = self.driver.get_current_url()
        self.assertEquals("http://localhost:%d/simpleTest.html"
                          % webserver.port, url)

    def testFindElementsByXPath(self):
        self._loadSimplePage()
        elem = self.driver.find_element_by_xpath("//h1")
        self.assertEquals("Heading", elem.get_text())
        
    def testFindElementByXpathThrowNoSuchElementException(self):
        self._loadSimplePage()
        try:
            self.driver.find_element_by_xpath("//h4")
        except NoSuchElementException:
            pass

    @not_available_on_remote #TODO: the remote driver is still giving NSE
    def testFindElementByXpathThrowErrorInResponseExceptionForInvalidXPath(self):
        self._loadSimplePage()
        try:
            self.driver.find_element_by_xpath("//a[")
        except NoSuchElementException, ex:
            self.fail(ex)
        except ErrorInResponseException:
            pass

    def testFindElementsByXpath(self):
        self._loadPage("nestedElements")
        elems = self.driver.find_elements_by_xpath("//option")
        self.assertEquals(48, len(elems))
        self.assertEquals("One", elems[0].get_value())

    def testFindElementsByName(self):
        self._loadPage("xhtmlTest")
        elem = self.driver.find_element_by_name("windowOne")
        self.assertEquals("Open new window", elem.get_text())

    def testFindElementsByNameInElementContext(self):
        self._loadPage("nestedElements")
        elem = self.driver.find_element_by_name("form2")
        sub_elem = elem.find_element_by_name("selectomatic")
        self.assertEquals("2", sub_elem.get_attribute("id"))

    def testFindElementsByLinkTextInElementContext(self):
        self._loadPage("nestedElements")
        elem = self.driver.find_element_by_name("div1")
        sub_elem = elem.find_element_by_link_text("hello world")
        self.assertEquals("link1", sub_elem.get_attribute("name"))

    def testFindElementByIdInElementContext(self):
        self._loadPage("nestedElements")
        elem = self.driver.find_element_by_name("form2")
        sub_elem = elem.find_element_by_id("2")
        self.assertEquals("selectomatic", sub_elem.get_attribute("name"))

    def testFindElementByXpathInElementContext(self):
        self._loadPage("nestedElements")
        elem = self.driver.find_element_by_name("form2")
        sub_elem = elem.find_element_by_xpath("select")
        self.assertEquals("2", sub_elem.get_attribute("id"))

    def testFindElementByXpathInElementContextNotFound(self):
        self._loadPage("nestedElements")
        elem = self.driver.find_element_by_name("form2")
        try:
            elem.find_element_by_xpath("div")
            self.fail()
        except NoSuchElementException:
            pass

    def testShouldBeAbleToEnterDataIntoFormFields(self):
        self._loadPage("xhtmlTest")
        elem = self.driver.find_element_by_xpath("//form[@name='someForm']/input[@id='username']")
        elem.clear()
        elem.send_keys("some text")
        elem = self.driver.find_element_by_xpath("//form[@name='someForm']/input[@id='username']")
        self.assertEquals("some text", elem.get_value())

    @not_available_on_remote
    def testFindElementByTagName(self):
        self._loadPage("simpleTest")
        elems = self.driver.find_elements_by_tag_name("div")
        num_by_xpath = len(self.driver.find_elements_by_xpath("//div"))
        self.assertEquals(num_by_xpath, len(elems))
        elems = self.driver.find_elements_by_tag_name("iframe")
        self.assertEquals(0, len(elems))

    @not_available_on_remote
    def testFindElementByTagNameWithinElement(self):
        self._loadPage("simpleTest")
        div = self.driver.find_element_by_id("multiline")
        elems = div.find_elements_by_tag_name("p")
        self.assertTrue(len(elems) == 1)

    def testSwitchToWindow(self):
        title_1 = "XHTML Test Page"
        title_2 = "We Arrive Here"
        self._loadPage("xhtmlTest")
        self.driver.find_element_by_link_text("Open new window").click()
        self.assertEquals(title_1, self.driver.get_title())
        try:
            self.driver.SwitchToWindow("result")
        except:
            # This may fail because the window is not loading fast enough, so try again
            time.sleep(1)
            self.driver.switch_to_window("result")
        self.assertEquals(title_2, self.driver.get_title())

    def testSwitchToFrameByIndex(self):
        self._loadPage("frameset")
        self.driver.switch_to_frame(2)
        self.driver.switch_to_frame(0)
        self.driver.switch_to_frame(2)
        checkbox = self.driver.find_element_by_id("checky")
        checkbox.toggle()
        checkbox.submit()
  
    def testSwitchFrameByName(self):
        self._loadPage("frameset")
        self.driver.switch_to_frame("third");
        checkbox = self.driver.find_element_by_id("checky")
        checkbox.toggle()
        checkbox.submit()

    def testGetPageSource(self):
        self._loadSimplePage()
        source = self.driver.get_page_source()
        self.assertTrue(len(re.findall(r'<html>.*</html>', source, re.DOTALL)) > 0)

    def testIsEnabled(self):
        self._loadPage("formPage")
        elem = self.driver.find_element_by_xpath("//input[@id='working']")
        self.assertTrue(elem.is_enabled())
        elem = self.driver.find_element_by_xpath("//input[@id='notWorking']")
        self.assertFalse(elem.is_enabled())

    def testIsSelectedAndToggle(self):
        self._loadPage("formPage")
        elem = self.driver.find_element_by_id("multi")
        option_elems = elem.find_elements_by_xpath("option")
        self.assertTrue(option_elems[0].is_selected())
        option_elems[0].toggle()
        self.assertFalse(option_elems[0].is_selected())
        option_elems[0].toggle()
        self.assertTrue(option_elems[0].is_selected())
        self.assertTrue(option_elems[2].is_selected())

    def testNavigate(self):
        self._loadPage("formPage")
        self.driver.find_element_by_id("imageButton").submit()
        self.assertEquals("We Arrive Here", self.driver.get_title())
        self.driver.back()
        self.assertEquals("We Leave From Here", self.driver.get_title())
        self.driver.forward()
        self.assertEquals("We Arrive Here", self.driver.get_title())

    def testGetAttribute(self):
        self._loadPage("xhtmlTest")
        elem = self.driver.find_element_by_id("id1")
        self.assertEquals("#", elem.get_attribute("href"))

    def testGetImplicitAttribute(self):
        self._loadPage("nestedElements")
        elems = self.driver.find_elements_by_xpath("//option")
        for i in range(3):
            self.assertEquals(i, int(elems[i].get_attribute("index")))

    def testExecuteSimpleScript(self):
        self._loadPage("xhtmlTest")
        title = self.driver.execute_script("return document.title;")
        self.assertEquals("XHTML Test Page", title)

    def testExecuteScriptAndReturnElement(self):
        self._loadPage("xhtmlTest")
        elem = self.driver.execute_script("return document.getElementById('id1');")
        self.assertTrue("WebElement" in str(type(elem)))

    def testExecuteScriptWithArgs(self):
        self._loadPage("xhtmlTest")
        result = self.driver.execute_script("return arguments[0] == 'fish' ? 'fish' : 'not fish';", "fish")
        self.assertEquals("fish", result)

    def testExecuteScriptWithElementArgs(self):
        self._loadPage("javascriptPage")
        button = self.driver.find_element_by_id("plainButton")
        result = self.driver.execute_script("arguments[0]['flibble'] = arguments[0].getAttribute('id'); return arguments[0]['flibble'];", button)
        self.assertEquals("plainButton", result)

    @not_available_on_remote
    def testFindElementsByPartialLinkText(self):
        """PartialLink match is not yet implemented on Remote Driver"""
        self._loadPage("xhtmlTest")
        elem = self.driver.find_element_by_partial_link_text("new window")
        elem.click()

    @not_available_on_remote
    def testScreenshot(self):
        self._loadPage("simpleTest")
        file_name = os.path.join(tempfile.mkdtemp(), "screenshot.png")
        self.driver.save_screenshot(file_name)
        self.assertTrue(os.path.exists(file_name))
        shutil.rmtree(os.path.dirname(file_name))    

    def _loadSimplePage(self):
        self.driver.get("http://localhost:%d/simpleTest.html" % webserver.port)

    def _loadPage(self, name):
        self.driver.get("http://localhost:%d/%s.html" % (webserver.port, name))

def run_tests(driver_):
    global driver
    driver = driver_
    utils.run_tests("api_examples.ApiExampleTest", driver, webserver)
