//Very cut-down and slightly modified (generally to remove context) from
//$WEBDRIVER_HOME/firefox/src/extension/components/utils.js

function Utils() {
}

function getTextFromNode(node, toReturn, textSoFar, isPreformatted) {
    if (node['tagName'] && node.tagName == "SCRIPT") {
        return [toReturn, textSoFar];
    } else if (node['tagName'] && node.tagName == "TITLE") {
        return [textSoFar + node.text, ""];
    }
    var children = node.childNodes;

    for (var i = 0; i < children.length; i++) {
        var child = children[i];

        // Do we need to collapse the text so far?
        if (child["tagName"] && child.tagName == "PRE") {
            toReturn += collapseWhitespace(textSoFar);
            textSoFar = "";
            var bits = getTextFromNode(child, toReturn, "", true);
            toReturn += bits[1];
            continue;
        }

        // Or is this just plain text?
        if (child.nodeName == "#text") {
            if (Utils.isDisplayed(child)) {
                var textToAdd = child.nodeValue;
                textToAdd = textToAdd.replace(new RegExp(String.fromCharCode(160), "gm"), " ");
                textSoFar += textToAdd;
            }
            continue;
        }

        // Treat as another child node.
        var bits = getTextFromNode(child, toReturn, textSoFar, false);
        toReturn = bits[0];
        textSoFar = bits[1];
    }

    if (isBlockLevel(node)) {
        if (node["tagName"] && node.tagName != "PRE") {
            toReturn += collapseWhitespace(textSoFar) + "\n";
            textSoFar = "";
        } else {
            toReturn += "\n";
        }
    }
    return [toReturn, textSoFar];
}
;

function isBlockLevel(node) {
    if (node["tagName"] && node.tagName == "BR")
        return true;

    try {
        // Should we think about getting hold of the current document?
        return "block" == Utils.getStyleProperty(node, "display");
    } catch (e) {
        return false;
    }
};

Utils.isInHead = function(element) {
  while (element) {
    if (element.tagName && element.tagName.toLowerCase() == "head") {
      return true;
    }
    try {
      element = element.parentNode;
    } catch (e) {
      // Fine. the DOM has dispeared from underneath us
      return false;
    }
  }

  return false;
};

Utils.isDisplayed = function(element) {
    // Ensure that we're dealing with an element.
    var el = element;
    while (el.nodeType != 1 && !(el.nodeType >= 9 && el.nodeType <= 11)) {
        el = el.parentNode;
    }

    // Hidden input elements are, by definition, never displayed
    if (el.tagName == "input" && el.type == "hidden") {
      return false;
    }

    var visibility = Utils.getStyleProperty(el, "visibility");

    var _isDisplayed = function(e) {
      var display = e.ownerDocument.defaultView.getComputedStyle(e, null).getPropertyValue("display");
      if (display == "none") return display;
      if (e && e.parentNode && e.parentNode.style) {
        return _isDisplayed(e.parentNode);
      }
      return undefined;
    };

    var displayed = _isDisplayed(el);

    if (element.scrollIntoView && element.getBoundingClientRect &&
        element.tagName.toLowerCase() != "option") {
      //Option tags have 0-dimension bounding rects so ignore them
      element.scrollIntoView(true);
      var clientRect = element.getBoundingClientRect();
      if (clientRect.width == 0 || clientRect.height == 0) {
        return false;
      }
    }
    
    return displayed != "none" && visibility != "hidden";
};

Utils.getStyleProperty = function(node, propertyName) {
    if (!node)
      return undefined;

    var value = node.ownerDocument.defaultView.getComputedStyle(node, null).getPropertyValue(propertyName);

    // Convert colours to hex if possible
    var raw = /rgb\((\d{1,3}),\s(\d{1,3}),\s(\d{1,3})\)/.exec(value);
    if (raw) {
        var temp = value.substr(0, raw.index);

        var hex = "#";
        for (var i = 1; i <= 3; i++) {
            var colour = (raw[i] - 0).toString(16);
            if (colour.length == 1)
                colour = "0" + colour;
            hex += colour
        }
        hex = hex.toLowerCase();
        value = temp + hex + value.substr(raw.index + raw[0].length);
    }

    if (value == "inherit" && element.parentNode.style) {
      value = Utils.getStyleProperty(node.parentNode, propertyName);
    }

    return value;
};

function collapseWhitespace(textSoFar) {
    return textSoFar.replace(/\s+/g, " ");
}
;

function getPreformattedText(node) {
    var textToAdd = "";
    return getTextFromNode(node, "", textToAdd, true)[1];
}
;

function isWhiteSpace(character) {
    return character == '\n' || character == ' ' || character == '\t' || character == '\r';
}

Utils.getText = function(element) {
    var bits = getTextFromNode(element, "", "", element.tagName == "PRE");
    var text = bits[0] + collapseWhitespace(bits[1]);
    var start = 0;
    while (start < text.length && isWhiteSpace(text[start])) {
        ++start;
    }
    var end = text.length;
    while (end > start && isWhiteSpace(text[end - 1])) {
        --end;
    }
    return text.slice(start, end);
};

Utils.fireHtmlEvent = function(element, eventName) {
    var e = document.createEvent("HTMLEvents");
    e.initEvent(eventName, true, true);
    element.dispatchEvent(e);
};


Utils.fireMouseEventOn = function(element, eventName) {
    Utils.triggerMouseEvent(element, eventName, 0, 0);
};

Utils.triggerMouseEvent = function(element, eventType, clientX, clientY) {
    var event = element.ownerDocument.createEvent("MouseEvents");
    var view = element.ownerDocument.defaultView;

    event.initMouseEvent(eventType, true, true, view, 1, 0, 0, clientX, clientY, false, false, false, false, 0, element);
    element.dispatchEvent(event);
};
