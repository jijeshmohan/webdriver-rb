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

package org.openqa.selenium.internal;

import org.openqa.selenium.Cookie;

import java.net.InetAddress;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.UnknownHostException;
import java.util.Date;
import java.text.SimpleDateFormat;

public class ReturnedCookie extends Cookie {
  private final boolean isSecure;

  public ReturnedCookie(String name, String value, String domain, String path, Date expiry, boolean isSecure) {
    super(name, value, domain, path, expiry);

    this.isSecure = isSecure;

    validate();
  }

  public boolean isSecure() {
    return isSecure;
  }

  @Override
  protected void validate() {
    super.validate();

    String domain = getDomain();

    if (domain != null && !"".equals(domain)) {
      try {
        String domainToUse = domain.startsWith("http") ? domain : "http://" + domain;
        URL url = new URL(domainToUse);
        InetAddress.getByName(url.getHost());
      } catch (MalformedURLException e) {
        throw new IllegalArgumentException(String.format("URL not valid: %s", domain));
      } catch (UnknownHostException e) {
        throw new IllegalArgumentException(String.format("Domain does not exist: %s", domain));
      }
    }
  }

  @Override
  public String toString() {
    return getName() + "=" + getValue()
        + ("".equals(getPath()) ? "" : ";path=" + getPath())
        + (getExpiry() == null ? "" : ";expires=" + new SimpleDateFormat("EEE, d MMM yyyy hh:mm:ss z").format(getExpiry()))
        + (isSecure ? ";secure;" : "");
  }
}
