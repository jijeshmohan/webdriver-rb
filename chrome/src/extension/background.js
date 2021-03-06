/** @namespace */
ChromeDriver = {};


/**
 * Array of all information about currently loaded tabs (where a WebDriver
 * window is probably a tab)
 * Entries of form:
 * {Int tabId, String windowName, Port mainPort, Boolean isFrameset, FrameData[] frames}
 * FrameData ::= {[Int frameId], String frameName, Port framePort, FrameData[]}
 * frameId can be undefined, if it has not yet been looked up, but should be
 * added once it is known
 * @type {Array.<Object>}  TODO(jmleyba): Type info
 */
ChromeDriver.tabs = [];


/**
 * Port to the currently active frame (or tab, if the current page is not a
 * frameset).
 * @type {?Port}
 */
ChromeDriver.activePort = null;


/**
 * ID of the currently active tab.
 * @type {?string}
 */
ChromeDriver.activeTabId = null;


/**
 * Whether we should switch to the next tab which opens. Should be set if the
 * last active tab was closed.
 * @type {boolean}
 */
ChromeDriver.doFocusOnNextOpenedTab = true;


/**
 * Place to temporarily store the URL currently being loaded, so that we can
 * retry if needed, because opening a URL is an async callback.
 * @type {?string}
 */
ChromeDriver.urlBeingLoaded = null;


/**
 * URL we believe we're currently on.
 * @type {?string}
 */
ChromeDriver.currentUrl = null;


/**
 * Whether we are loading a new URL that difers from the current URL only in
 * fragment.
 * @type {boolean}
 */
ChromeDriver.isGettingUrlButOnlyChangingByFragment = false;


/**
 * Whether we are currently executing a {@code ChromeDriver#close()}, and
 * accordingly should send a success response when the tab closes.
 * @type {boolean}
 */
ChromeDriver.isClosingTab = false;


/**
 * Whether we have sent a response to the {currently, most recently loading
 * page.
 * @type {boolean}
 */
ChromeDriver.hasSentResponseToThisPageLoading = false;


/**
 * Whether we believe a page is open to which we have no content script.
 * @type {boolean}
 */
ChromeDriver.hasNoConnectionToPage = true;


/**
 * Stores the remaining frames to traverse when switching frames.
 * @type {Array.<string>}
 */
ChromeDriver.restOfCurrentFramePath = [];


/**
 * Port to the frameset or main content page we currently have loaded, so that
 * we can probe it for information about its frames.
 * @type {?Port}
 */
ChromeDriver.portToUseForFrameLookups = null;


/**
 * The last request we sent that has not been answered, so that if we change
 * page between sending a request and receiving a response, we can re-send it to
 * the newly loaded page.
 * @type {*}  TODO(jmleyba)
 */
ChromeDriver.lastRequestToBeSentWhichHasntBeenAnsweredYet = null;


/**
 * Whether the plugin has the OS-specific window handle for the active tab. This
 * is called HWND rather than window handle to avoid confusion with the other
 * use of window handle to mean 'name of window'.
 * @type {boolean}
 */
ChromeDriver.hasHwnd = false;


/**
 * THe last XMLHttpRequest we made (used for communication with test language
 * bindings).
 * @type {?XMLHttpRequest}
 */
ChromeDriver.xmlHttpRequest = null;

/**
 * URL to ping for commands.
 * TODO(danielwh): Get this from the initial URL - see http://crbug.com/11547,
 * the ChromeDriverInternals wiki page.
 * There is a patch to fix this on the Downloads page of the Selenium project
 * @type {string}
 */
ChromeDriver.xmlHttpRequestUrl = "http://127.0.0.1:9700/chromeCommandExecutor";


/**
 * @type {number}
 */
ChromeDriver.requestSequenceNumber = 0;


/**
 * @type {number}
 */
ChromeDriver.getUrlRequestSequenceNumber = 0;


/**
 * Prefix prepended to the hopefully unique javascript window name, in hopes of
 * further removing conflict.
 * @type {string}
 */
ChromeDriver.windowHandlePrefix = '__webdriver_chromedriver_windowhandle';


/**
 * Whether we will not execute any commands because we are already executing
 * one.
 * @type {boolean}
 */
ChromeDriver.isBlockedWaitingForResponse = false;


chrome.extension.onConnect.addListener(function(port) {
  console.log("Connected to " + port.name);
  // Note: The frameset port *always* connects before any frame port.  After
  // that, the order is in page loading time
  ChromeDriver.hasNoConnectionToPage = false;
  var foundTab = false;
  for (var tab in ChromeDriver.tabs) {
    if (ChromeDriver.tabs[tab].tabId == port.tab.id) {
      //We must be a new [i]frame in the page, because when a page closes, it is
      // removed from ChromeDriver.tabs
      //TODO(danielwh): Work out WHICH page it's a sub-frame of (I don't look
      // forward to this)
      ChromeDriver.tabs[tab].frames.push({
        frameName: port.name,
        framePort: port,
        frames: []
      });
      //Loaded a frame.  Pushed it to the array.  We don't know which page it's
      // a sub-frame of, in the case of nested frames, if they have the same
      // names.  It would be nice to think people didn't use frames, let alone
      // several layers of nesting of frames with the same name, but if it turns
      // out to be a problem... Well, we'll see.
      foundTab = true;
      break;
    }
  }
  if (!foundTab) {
    //New tab!
    //We don't know if it's a frameset yet, so we leave that as undefined
    ChromeDriver.tabs.push({
      tabId: port.tab.id,
      windowName: ChromeDriver.windowHandlePrefix + "_" + port.tab.id,
      mainPort: port,
      frames: []
    });
  }
  
  if (ChromeDriver.doFocusOnNextOpenedTab) {
    ChromeDriver.activePort = port;
    setActiveTabDetails(port.tab);
    //Re-parse the last request we sent if we didn't get a response,
    //because we ain't seeing a response any time soon
    
    if (ChromeDriver.lastRequestToBeSentWhichHasntBeenAnsweredYet != null) {
      if (ChromeDriver.urlBeingLoaded != null) {
        ChromeDriver.lastRequestToBeSentWhichHasntBeenAnsweredYet = null;
      } else {
        ChromeDriver.isBlockedWaitingForResponse = false;
        console.log("Re-trying request which was sent but not answered");
        parseRequest(ChromeDriver.lastRequestToBeSentWhichHasntBeenAnsweredYet);
      }
    }
  }
  
  if (ChromeDriver.urlBeingLoaded != null) {
    //This was the result of a getUrl.  Need to issue a response
    sendEmptyResponseWhenTabIsLoaded(port.tab);  
  }
  port.onMessage.addListener(parsePortMessage);
  port.onDisconnect.addListener(function disconnectPort(port) {
    console.log("Disconnected from " + port.name);
    var remainingTabs = [];
    for (var tab in ChromeDriver.tabs) {
      if (ChromeDriver.tabs[tab].tabId == port.tab.id) {
        if (ChromeDriver.tabs[tab].mainPort == port) {
          //This main tab is being closed.
          //Don't include it in the new version of ChromeDriver.tabs.
          //Any subframes will also disconnect,
          //but their tabId won't be present in the array,
          //so they will be ignored.
          continue;
        } else {
          //This is a subFrame being ditched
          var remainingFrames = [];
          for (var frame in ChromeDriver.tabs[tab].frames) {
            if (ChromeDriver.tabs[tab].frames[frame].framePort == port) {
              continue;
            }
            remainingFrames.push(ChromeDriver.tabs[tab].frames[frame]);
          }
          ChromeDriver.tabs[tab].frames = remainingFrames;
        }
      }
      remainingTabs.push(ChromeDriver.tabs[tab]);
    }
    ChromeDriver.tabs = remainingTabs;
    if (ChromeDriver.tabs.length == 0 || ChromeDriver.activePort == null ||
        ChromeDriver.activePort.tab.id == port.tab.id) {
      //If it is the active tab, perhaps we have followed a link,
      //so we should focus on it.
      //We have nothing better to focus on, anyway.
      resetActiveTabDetails();
    }
    if (ChromeDriver.isClosingTab) {
      //We are actively closing the tab, and expect a response to this
      sendResponseToParsedRequest({statusCode: 0}, false)
      ChromeDriver.isClosingTab = false;
    }
  });
});

//Tell the ChromeCommandExecutor that we are here
sendResponseByXHR({statusCode: 0}, false);

/**
 * Sends the passed argument as the result of a command
 * @param result result to send
 * @param wait whether we expect this command to possibly make changes
 * we need to wait for (e.g. adding elements, opening windows) - if so,
 * we wait until we think these effects are done
 */
function sendResponseByXHR(result, wait) {
  console.log("Sending result by XHR: " + result);
  if (ChromeDriver.xmlHttpRequest != null) {
    ChromeDriver.xmlHttpRequest.abort();
  }
  ChromeDriver.xmlHttpRequest = new XMLHttpRequest();
  ChromeDriver.xmlHttpRequest.onreadystatechange =
      handleXmlHttpRequestReadyStateChange;
  ChromeDriver.xmlHttpRequest.open(
      "POST", ChromeDriver.xmlHttpRequestUrl, true);
  ChromeDriver.xmlHttpRequest.setRequestHeader(
      "Content-type", "application/json");
  //Default to waiting for page changes, just in case
  //TODO(danielwh): Iterate over tabs checking their status
  if (typeof(wait) == "undefined" || wait == null || wait) {
    setTimeout(sendResult, 600, [result]);
  } else {
    sendResult(result);
  }
}

/**
 * Actually sends the result by XHR
 * Should only EVER be called by sendResponseByXHR,
 * as it ignores things like setting up XHR and blocking,
 * and just forces the sending over an assumed open XHR
 */
function sendResult(result) {
  //TODO(danielwh): Iterate over tabs checking their status
  ChromeDriver.xmlHttpRequest.send(result + "\nEOResponse\n");
  console.log("Sent result by XHR: " + result);
}

/**
 * Sends the response to a request, which has been parsed by parseRequest
 * Should be used only from within parseRequest (or methods called from it),
 * because it adheres to the blocking semantics of parseRequest
 */
function sendResponseToParsedRequest(toSend, wait) {
  if (!ChromeDriver.isBlockedWaitingForResponse) {
    console.log("Tried to send a response (" + toSend +
                ") when not waiting for one.  Dropping response.");
    return;
  }
  ChromeDriver.isBlockedWaitingForResponse = false;
  ChromeDriver.lastRequestToBeSentWhichHasntBeenAnsweredYet = null;
  console.log("SENDING RESPOND TO PARSED REQUEST");
  sendResponseByXHR(JSON.stringify(toSend), wait);
  setToolstripsBusy(false);
}

/**
 * When we receive a request, dispatches parseRequest to execute it
 */
function handleXmlHttpRequestReadyStateChange() {
  if (this.readyState == 4) {
    if (this.status != 200) {
      console.log("Request state was 4 but status: " + this.status +
                  ".  responseText: " + this.responseText);
    } else {
      console.log("GOT XHR RESPONSE: " + this.responseText);
      var request = JSON.parse(this.responseText);
      if (request.request == "quit") {
        //We're only allowed to send a response if we're blocked waiting for one, so pretend
        console.log("SENDING QUIT XHR");
        sendResponseByXHR(JSON.stringify({statusCode: 0}), false);
      } else {
        console.log("Got request to execute from XHR: " + this.responseText);
        parseRequest(request);
      }
    }
  }
}

/**
 * Parses a request received from the ChromeCommandExecutor and either sends the
 * response, or sends a message to the content script with a command to execute
 * @param request object encapsulating the request (e.g.
 *     {request: url, url: "http://www.google.co.uk"})
 */
function parseRequest(request) {
  if (ChromeDriver.isBlockedWaitingForResponse) {
    console.log("Already sent a request which hasn't been replied to yet. " +
                "Not parsing any more.");
    return;
  }
  ChromeDriver.isBlockedWaitingForResponse = true;
  setToolstripsBusy(true);
  
  switch (request.request) {
  case "get":
    getUrl(request.url);
    break;
  case "close":
    //Doesn't re-focus the ChromeDriver.activePort on any tab.
    chrome.tabs.remove(ChromeDriver.activeTabId);
    ChromeDriver.isClosingTab = true;
    break;
  case "getCurrentWindowHandle":
    //TODO(danielwh): Get window's handle, not frame's
    var handle =
        (ChromeDriver.activePort == null ? ChromeDriver.activePort.name : "");
    sendResponseToParsedRequest({statusCode: 0, value:  handle}, false);
    break;
  case "getWindowHandles":
    sendResponseToParsedRequest(getWindowHandles(), false);
    break;
  case "switchToDefaultContent":
    switchToDefaultContent();
    break;
  case "switchToFrameByIndex":
    switchToFrame(null, request.index);
    break;
  case "switchToFrameByName":
    switchToFrame(request.name, null);
    break;
  case "switchToWindow":
    ChromeDriver.hasHwnd = false;
    if (typeof("request.windowName") != "undefined") {
      setActivePortByWindowName(request.windowName);
    } else {
      sendResponseToParsedRequest({
        statusCode: 3,
        value: {
          message: 'Window to switch to was not given'
        }
      }, false);
    }
    break;
  case "clickElement":
  case "hoverOverElement":
    // Falling through, as native events are handled the same
  case "sendKeysToElement":
    if (typeof(request.keys) == "object" && request.keys.length !== undefined) {
      request.keys = request.keys.join("");
    }
    sendMessageOnActivePortAndAlsoKeepTrackOfIt(
        wrapInjectEmbedIfNecessary(request));
    break;
  case "getCurrentUrl":
  case "getTitle":
    if (hasNoPage()) {
      console.log("Not got a page, but asked for string, so sending empty string");
      sendResponseToParsedRequest({statusCode: 0, value: ''});
      break;
    }
    // Falling through, as if we do have a page, we want to treat this like a
    // normal request
  case "findElement":
  case "findChildElement":
    if (hasNoPage()) {
      console.log("Not got a page, but asked for element, so throwing NoSuchElementException");
      sendResponseToParsedRequest({statusCode: 7, value: {message: 'Was not on a page, so could not find elements'}});
      break;
    }
    // Falling through, as if we do have a page, we want to treat this like a
    // normal request
  case "findElements":
  case "findChildElements":
    if (hasNoPage()) {
      console.log("Not got a page, but asked for elements, so returning no elements");
      sendResponseToParsedRequest({statusCode: 0, value: []});
      break;
    }
  // Falling through, as if we do have a page, we want to treat this like a
  // normal request
  case "deleteAllCookies":
  case "deleteCookie":
    if (hasNoPage()) {
      console.log("Not got a page, but asked to delete cookies, so returning ok");
      sendResponseToParsedRequest({statusCode: 0});
      break;
    }
  // Falling through, as if we do have a page, we want to treat this like a
  // normal request
  default:
    var sequenceNumber = ChromeDriver.requestSequenceNumber;
    ChromeDriver.requestSequenceNumber++;
    sendMessageOnActivePortAndAlsoKeepTrackOfIt({
      request: request,
      sequenceNumber: sequenceNumber
    });
    break;
  }
}


function sendMessageOnActivePortAndAlsoKeepTrackOfIt(message) {
  ChromeDriver.lastRequestToBeSentWhichHasntBeenAnsweredYet = message.request;
  try {
    ChromeDriver.activePort.postMessage(message);
  } catch (e) {
    console.log("Tried to send request without an active port.  " +
                "Request will retry when connected, but will hang until then.");
  }
}

/**
 * Parse messages coming in on the port (responses from the content script).
 * @param message JSON message of format:
 *                {response: "some command",
 *                 value: {statusCode: STATUS_CODE
 *                 [, optional params]}}
 */
function parsePortMessage(message) {
  console.log(
      "Received response from content script: " + JSON.stringify(message));
  if (!message || !message.response || !message.response.value ||
      typeof(message.response.value.statusCode) == "undefined" ||
      message.response.value.statusCode == null ||
      typeof(message.sequenceNumber) == "undefined") {
    // Should only ever happen if we sent a bad request,
    // or the content script is broken
    console.log("Got invalid response from the content script.");
    return;
  }
  var toSend = {statusCode: 12};
  ChromeDriver.lastRequestToBeSentWhichHasntBeenAnsweredYet = null;
  switch (message.response.value.statusCode) {
  // Error codes are loosely based on native exception codes, see
  // common/src/cpp/webdriver-interactions/errorcodes.h
  case 0:
  case 2: //org.openqa.selenium.WebDriverException [Cookies]
  case 3: //org.openqa.selenium.NoSuchWindowException
  case 7: //org.openqa.selenium.NoSuchElementException
  case 8: //org.openqa.selenium.NoSuchFrameException
  case 9: //java.lang.UnsupportedOperationException [Unknown command]
  case 10: //org.openqa.selenium.StaleElementReferenceException
  case 11: //org.openqa.selenium.ElementNotVisibleException
  case 12: //java.lang.UnsupportedOperationException [Invalid element state ]
  case 17: //org.openqa.selenium.WebDriverException [Bad javascript]
  case 19: //org.openqa.selenium.XPathLookupException
  case 99: //org.openqa.selenium.WebDriverException [Native event]
    toSend = {statusCode: message.response.value.statusCode, value: null};
    if (typeof(message.response.value) != "undefined" && message.response.value != null &&
        typeof(message.response.value.value) != "undefined") {
      toSend.value = message.response.value.value;
    }
    sendResponseToParsedRequest(toSend, message.response.wait);
    break;
  case "no-op":
    //Some special operation which isn't sending HTTP
    switch (message.response.response) {
    case "clickElement":
      try {
        if (document.embeds[0].clickAt(message.response.value.x, message.response.value.y)) {
          sendResponseToParsedRequest({statusCode: 0}, true);
        } else {
          sendResponseToParsedRequest({statusCode: 99}, true);
        }
      } catch(e) {
        console.log("Error natively clicking.  Trying non-native.");
        ChromeDriver.isBlockedWaitingForResponse = false;
        parseRequest({
          request: 'nonNativeClickElement',
          elementId: message.response.value.elementId
        });
      }
      break;
    case "hoverElement":
      try {
        var points = message.response.value;
        if (document.embeds[0].mouseMoveTo(15, points.oldX, points.oldY, points.newX, points.newY)) {
          sendResponseToParsedRequest({statusCode: 0}, true);
        } else {
          sendResponseToParsedRequest({statusCode: 99}, true);
        }
      } catch(e) {
        sendResponseToParsedRequest({statusCode: 99}, true);
      }
      break;
    case "sendKeysToElement":
      try {
        if (document.embeds[0].sendKeys(message.response.value.keys)) {
          sendResponseToParsedRequest({statusCode: 0}, true);
        } else {
          sendResponseToParsedRequest({statusCode: 99}, true);
        }
      } catch(e) {
        console.log("Error natively sending keys.  Trying non-native.");
        ChromeDriver.isBlockedWaitingForResponse = false;
        parseRequest({
          request: 'sendElementNonNativeKeys',
          elementId: message.response.value.elementId,
          keys: message.response.value.keys
        });
      }
      break;
    case "sniffForMetaRedirects":
      if (!message.response.value.value &&
          !ChromeDriver.hasSentResponseToThisPageLoading) {
        ChromeDriver.urlBeingLoaded = null;
        ChromeDriver.hasSentResponseToThisPageLoading = true;
        switchToDefaultContent();
      }
      break;
    case "newTabInformation":
      var response = message.response.value;
      for (var tab in ChromeDriver.tabs) {
        //RACE CONDITION!!!
        //This call should happen before another content script
        //connects and returns this value,
        //but if it doesn't, we may get mismatched information
        if (typeof(ChromeDriver.tabs[tab].isFrameset) == "undefined") {
          ChromeDriver.tabs[tab].isFrameset = response.isFrameset;
          return;
        } else {
          for (var frame in ChromeDriver.tabs[tab].frames) {
            var theFrame = ChromeDriver.tabs[tab].frames[frame];
            if (typeof(theFrame.isFrameset) == "undefined") {
              theFrame.isFrameset = response.isFrameset;
              return;
            }
          }
        }
      }
      break;
    case "getFrameNameFromIndex":
      var newName = message.response.value.name;
      if (ChromeDriver.restOfCurrentFramePath.length != 0) {
        newName += "." + ChromeDriver.restOfCurrentFramePath.join(".");
      }
      switchToFrameByName(newName);
      break;
    }
    break;
  }
}

/**
 * If the plugin doesn't currently have an HWND for this page,
 * we need to get one by injecting an embed
 */
function wrapInjectEmbedIfNecessary(requestObject) {
  if (ChromeDriver.hasHwnd) {
    var sequenceNumber = ChromeDriver.requestSequenceNumber;
    ChromeDriver.requestSequenceNumber++;
    return {
      sequenceNumber: sequenceNumber,
      request: requestObject
    };
  } else {
    var wrappedObject = {
      sequenceNumber: ChromeDriver.requestSequenceNumber,
      request: {
        request: "injectEmbed",
        followup: {
          sequenceNumber: ChromeDriver.requestSequenceNumber + 1,
          request: requestObject
        }
      }
    };
    ChromeDriver.requestSequenceNumber += 2;
    return wrappedObject;
  }
}

/**
 * Gets all current window handles
 * @return an array containing all of the current window handles
 */
function getWindowHandles() {
  var windowHandles = [];
  for (var tab in ChromeDriver.tabs) {
    windowHandles.push(ChromeDriver.tabs[tab].windowName);
  }
  return {statusCode: 0, value: windowHandles}
}

function resetActiveTabDetails() {
  ChromeDriver.activePort = null;
  ChromeDriver.hasHwnd = false;
  ChromeDriver.activeTabId = null;
  ChromeDriver.doFocusOnNextOpenedTab = true;
  ChromeDriver.hasSentResponseToThisPageLoading = false;
  ChromeDriver.portToUseForFrameLookups = null;
  ChromeDriver.currentUrl = null;
}

function setActiveTabDetails(tab) {
  ChromeDriver.activeTabId = tab.id;
  ChromeDriver.activeWindowId = tab.windowId;
  ChromeDriver.doFocusOnNextOpenedTab = false;
  ChromeDriver.currentUrl = tab.url;
}

function switchToDefaultContent() {
  ChromeDriver.hasHwnd = false;
  for (var tab in ChromeDriver.tabs) {
    if (ChromeDriver.tabs[tab].tabId == ChromeDriver.activeTabId) {
      if (ChromeDriver.tabs[tab].isFrameset) {
        ChromeDriver.isBlockedWaitingForResponse = false;
        parseRequest({request: 'switchToFrameByIndex', index: 0});
      } else {
        ChromeDriver.activePort = ChromeDriver.tabs[tab].mainPort;
        sendResponseToParsedRequest({statusCode: 0}, false);
      }
      return;
    }
  }
}

function switchToFrame(name, index) {
  ChromeDriver.hasHwnd = false;
  for (var tab in ChromeDriver.tabs) {
    if (ChromeDriver.tabs[tab].tabId == ChromeDriver.activeTabId) {
      ChromeDriver.portToUseForFrameLookups = ChromeDriver.tabs[tab].mainPort;
      break;
    }
  }
  if (name !== undefined && name != null) {
    switchToFrameByName(name);
  } else if (index !== undefined && index != null) {
    getFrameNameFromIndex(index);
  } else {
    sendResponseToParsedRequest({
      statusCode: 9,
      value: {
        message: "Switching frames other than by name or id is unsupported"
      }
    });
  }
}

function switchToFrameByName(name) {
  var names = name.split(".");
  
  for (var tab in ChromeDriver.tabs) {
    if (ChromeDriver.tabs[tab].tabId == ChromeDriver.activeTabId) {
      var frame;
      for (frame in ChromeDriver.tabs[tab].frames) {
        // Maybe name was a fully qualified name, which perhaps just happened to
        // include .s
        if (ChromeDriver.tabs[tab].frames[frame].frameName == name) {
          ChromeDriver.activePort =
              ChromeDriver.tabs[tab].frames[frame].framePort;
          ChromeDriver.restOfCurrentFramePath = [];
          sendResponseToParsedRequest({statusCode: 0}, false);
          return;
        }
      }
      for (frame in ChromeDriver.tabs[tab].frames) {
        // Maybe we're looking for a child, see if this is the parent of it
        if (ChromeDriver.tabs[tab].frames[frame].frameName == names[0]) {
          ChromeDriver.activePort =
              ChromeDriver.tabs[tab].frames[frame].framePort;
          ChromeDriver.portToUseForFrameLookups = ChromeDriver.activePort;
          names.shift();
          ChromeDriver.restOfCurrentFramePath = names;
          if (names.length == 0) {
            sendResponseToParsedRequest({statusCode: 0}, false);
            return;
          } else {
            switchToFrameByName(names.join("."));
            return;
          }
        }
      }
    }
  }
  
  //Maybe the "name" was actually an index? Let's find out...
  var index = null;
  try {
    index = parseInt(names[0]);
  } catch (e) {
  }
  if (!isNaN(index)) {
    names.shift();
    ChromeDriver.restOfCurrentFramePath = names;
    getFrameNameFromIndex(index);
    return;
  }

  ChromeDriver.isBlockedWaitingForResponse = false;
  parseRequest({request: 'switchToNamedIFrameIfOneExists', name: name});
}

function getFrameNameFromIndex(index) {
  var message = {
    request: {
      request: "getFrameNameFromIndex",
      index: index
    },
    sequenceNumber: ChromeDriver.requestSequenceNumber
  };
  ChromeDriver.requestSequenceNumber++;
  ChromeDriver.portToUseForFrameLookups.postMessage(message);
}

/**
 * Closes the current tab if it exists, and opens a new one, in which it
 * gets the URL passed
 * @param url the URL to load
 */
function getUrl(url) {
  ChromeDriver.urlBeingLoaded = url;
  var tempActiveTagId = ChromeDriver.activeTabId;
  if (url.indexOf("#") > -1 && ChromeDriver.currentUrl != null &&
      ChromeDriver.currentUrl.split("#")[0] == url.split("#")[0]) {
    ChromeDriver.isGettingUrlButOnlyChangingByFragment = true;
  } else {
    resetActiveTabDetails();
  }
  ChromeDriver.currentUrl = url;
  if (tempActiveTagId == null) {
    chrome.tabs.create({url: url, selected: true}, getUrlCallback);
  } else {
    ChromeDriver.activeTabId = tempActiveTagId;
    if (ChromeDriver.isGettingUrlButOnlyChangingByFragment) {
      chrome.tabs.update(ChromeDriver.activeTabId, {url: url, selected: true},
          getUrlCallback);
    } else {
      chrome.tabs.remove(ChromeDriver.activeTabId);
      chrome.tabs.create({url: url, selected: true}, getUrlCallback);
    }
  }
}

function getUrlCallback(tab) {
  if (chrome.extension.lastError) {
    // An error probably arose because Chrome didn't have a window yet
    // (see crbug.com 19846)
    // If we retry, we *should* be fine. Unless something really bad is
    // happening, in which case we will probably hang indefinitely trying to
    // reload the same URL
    getUrl(ChromeDriver.urlBeingLoaded);
    return;
  }
  if (tab == null) {
    //chrome.tabs.update's callback doesn't pass a Tab argument,
    //so we need to populate it ourselves
    chrome.tabs.get(ChromeDriver.activeTabId, getUrlCallback);
    return;
  }
  if (tab.status != "complete") {
    // Use the helper calback so that we actually get updated version of the tab
    // we're getting
    setTimeout("getUrlCallbackById(" + tab.id + ")", 10);
  } else {
    ChromeDriver.getUrlRequestSequenceNumber++;
    if (ChromeDriver.activePort == null) {
      ChromeDriver.hasNoConnectionToPage = true;
      sendEmptyResponseWhenTabIsLoaded(tab);
    }
    setActiveTabDetails(tab);
  }
  if (ChromeDriver.isGettingUrlButOnlyChangingByFragment) {
    ChromeDriver.urlBeingLoaded = null;
    sendResponseToParsedRequest({statusCode: 0}, false);
    ChromeDriver.isGettingUrlButOnlyChangingByFragment = false;
  }
}

function getUrlCallbackById(tabId) {
  chrome.tabs.get(tabId, getUrlCallback);
}

function sendEmptyResponseWhenTabIsLoaded(tab) {
  if (tab.status == "complete") {
    if (ChromeDriver.activePort) {
      ChromeDriver.isBlockedWaitingForResponse = false;
      parseRequest({request: 'sniffForMetaRedirects'});
    } else {
      if (!ChromeDriver.hasSentResponseToThisPageLoading) {
        ChromeDriver.urlBeingLoaded = null;
        sendResponseToParsedRequest({statusCode: 0}, false);
      }
    }
  } else {
    chrome.tabs.get(tab.id, sendEmptyResponseWhenTabIsLoaded);
  }
}
      

function setToolstripsBusy(busy) {
  var toolstrips = chrome.extension.getToolstrips(ChromeDriver.activeWindowId);
  for (var toolstrip in toolstrips) {
    if (toolstrips[toolstrip].setWebdriverToolstripBusy && 
        toolstrips[toolstrip].setWebdriverToolstripFree) {
      if (busy) {
        toolstrips[toolstrip].setWebdriverToolstripBusy();
      } else {
        toolstrips[toolstrip].setWebdriverToolstripFree();
      }
    }
  }
}

function setActivePortByWindowName(handle) {
  for (var tab in ChromeDriver.tabs) {
    if (ChromeDriver.tabs[tab].windowName == handle || 
        ChromeDriver.tabs[tab].mainPort.name == handle) {
      ChromeDriver.activePort = ChromeDriver.tabs[tab].mainPort;
      chrome.tabs.get(ChromeDriver.tabs[tab].tabId, setActiveTabDetails);
      chrome.tabs.update(ChromeDriver.tabs[tab].tabId, {selected: true});
      sendResponseToParsedRequest({statusCode: 0}, false);
      return;
    }
  }
  sendResponseToParsedRequest({statusCode: 3, value: {message: 'Could not find window to switch to by handle: ' + handle}}, false);
}


/**
 * @return {boolean} Whether there is currently no active page.
 */
function hasNoPage() {
  return ChromeDriver.hasNoConnectionToPage ||
         ChromeDriver.activePort == null ||
         ChromeDriver.activeTabId == null;
}
