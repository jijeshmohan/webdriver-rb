/*
Copyright 2009 WebDriver committers
Copyright 2009 Google Inc.

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

package org.openqa.selenium.firefox.internal;

import java.io.OutputStream;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Arrays;

/**
 * Captures the last N bytes of output.
 */
public class CircularOutputStream extends OutputStream {
  private static final int DEFAULT_SIZE = 4096;
  private int start;
  private int end;
  private boolean filled = false;
  private byte[] buffer;

  public CircularOutputStream(int maxSize) {
    buffer = new byte[maxSize];
  }

  public CircularOutputStream() {
    this(DEFAULT_SIZE);
  }

  @Override
  public void write(int b) throws IOException {
    if (end == buffer.length) {
      filled = true;
      end = 0;
    }

    if (filled && end == start) {
      start = start == buffer.length - 1 ? 0 : start + 1;
    }

    buffer[end++] = (byte) b;
  }

  @Override
  public String toString() {
    int size = filled ? buffer.length : end;
    byte[] toReturn = new byte[size];

    // Handle the partially filled array as a special case
    if (!filled) {
      System.arraycopy(buffer, 0, toReturn, 0, end);
      return new String(toReturn);
    }

    System.arraycopy(buffer, start, toReturn, 0, buffer.length - start);
    System.arraycopy(buffer, 0, toReturn, buffer.length - start, end);
    return new String(toReturn);
  }
}
