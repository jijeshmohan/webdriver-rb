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

// Copyright 2008 Google Inc.  All Rights Reserved.

package org.openqa.selenium.firefox.internal;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.channels.FileChannel;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Utility methods for common filesystem activities
 */
public class FileHandler {
  private static final int BUF_SIZE = 4098;
  private static final Method JDK6_SETWRITABLE = findJdk6SetWritableMethod();
  private static final File CHMOD_SETWRITABLE = findChmodCommand();

  public static File unzip(InputStream resource) throws IOException {
    File output = TemporaryFilesystem.createTempDir("unzip", "stream");
    
    ZipInputStream zipStream = new ZipInputStream(new BufferedInputStream(resource));
    ZipEntry entry = zipStream.getNextEntry();
    while (entry != null) {
      if (entry.isDirectory()) {
        createDir(new File(output, entry.getName()));
      } else {
        unzipFile(output, zipStream, entry.getName());
      }
      entry = zipStream.getNextEntry();
    }

    return output;
  }

  private static void unzipFile(File output, InputStream zipStream, String name)
      throws IOException {
    File toWrite = new File(output, name);

    if (!createDir(toWrite.getParentFile()))
       throw new IOException("Cannot create parent director for: " + name);

    FileOutputStream out = new FileOutputStream(toWrite);
    try {
      byte[] buffer = new byte[BUF_SIZE];
      int read;
      while ((read = zipStream.read(buffer)) != -1) {
        out.write(buffer, 0, read);
      }
    } finally {
      out.close();
    }
  }

  public static boolean createDir(File dir) throws IOException {
    if ((dir.exists() || dir.mkdirs()) && dir.canWrite())
      return true;

    if (dir.exists()) {
      FileHandler.makeWritable(dir);
      return dir.canWrite();
    }

    // Iterate through the parent directories until we find that exists,
    // then sink down.
    return createDir(dir.getParentFile());
  }

  public static boolean makeWritable(File file) throws IOException {
    if (file.canWrite()) {
      return true;
    }

    if (JDK6_SETWRITABLE != null) {
      try {
        return (Boolean) JDK6_SETWRITABLE.invoke(file, true);
      } catch (IllegalAccessException e) {
        // Do nothing. We return false in the end
      } catch (InvocationTargetException e) {
        // Do nothing. We return false in the end
      }
    } else if (CHMOD_SETWRITABLE != null) {
      try {
        Process process = Runtime.getRuntime().exec(
            new String[]{CHMOD_SETWRITABLE.getAbsolutePath(), "+x", file.getAbsolutePath()});
        process.waitFor();
        return file.canWrite();
      } catch (InterruptedException e1) {
        throw new RuntimeException(e1);
      }
    }
    return false;
  }

  public static boolean isZipped(String fileName) {
    return fileName.endsWith(".zip") || fileName.endsWith(".xpi");
  }

  public static boolean delete(File toDelete) {
    boolean deleted = true;

    if (toDelete.isDirectory()) {
      for (File child : toDelete.listFiles()) {
        deleted &= child.canWrite() && delete(child);
      }
    }

    return deleted && toDelete.canWrite() && toDelete.delete();
  }
  
  public static void copy(File from, File to) throws IOException {
    if (!from.exists()) {
      return;
    }
    
    if (from.isDirectory()) {
      copyDir(from, to);
    } else {
      copyFile(from, to);
    }
  }

  private static void copyDir(File from, File to) throws IOException {
    // Create the target directory.
    createDir(to);

    // List children.
    String[] children = from.list();
    for (String child : children) {
      if (!".parentlock".equals(child) && !"parent.lock".equals(child)) {
        copy(new File(from, child), new File(to, child));
      }
    }
  }

  private static void copyFile(File from, File to) throws IOException{
    FileChannel out = null;
    FileChannel in = null;
    try {
      in = new FileInputStream(from).getChannel();
      out = new FileOutputStream(to).getChannel();
      final long length = in.size();
      
      final long copied = in.transferTo(0, in.size(), out);
      if (copied != length) {
        throw new IOException("Could not transfer all bytes.");
      }
    } finally {
      Cleanly.close(out);
      Cleanly.close(in);
    }
  }

  /**
   * File.setWritable appears in Java 6. If we find the method,
   * we can use it
   */
  private static Method findJdk6SetWritableMethod() {
    try {
      return File.class.getMethod("setWritable", Boolean.class);
    } catch (NoSuchMethodException e) {
      return null;
    }
  }
  
  /**
   * In JDK5 and earlier, we have to use a chmod command from the path.
   */
  private static File findChmodCommand() {
    
    // Search the path for chmod
    String allPaths = System.getenv("PATH");
    String[] paths = allPaths.split(File.pathSeparator);
    for (String path : paths) {
      File chmod = new File(path, "chmod");
      if (chmod.exists()) {
        return chmod;
      }
    }
    return null;
  }
}
