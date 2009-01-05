/*
Copyright 2007-2009 WebDriver committers
Copyright 2007-2009 Google Inc.
Portions copyright 2007 ThoughtWorks, Inc

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

/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class org_openqa_selenium_ie_InternetExplorerDriver */

#ifndef _Included_org_openqa_selenium_ie_InternetExplorerDriver
#define _Included_org_openqa_selenium_ie_InternetExplorerDriver
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    getPageSource
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_getPageSource
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    close
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_close
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    doExecuteScript
 * Signature: (Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;
 */
JNIEXPORT jobject JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_doExecuteScript
  (JNIEnv *, jobject, jstring, jobjectArray);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    get
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_get
  (JNIEnv *, jobject, jstring);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    getCurrentUrl
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_getCurrentUrl
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    getTitle
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_getTitle
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    getVisible
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_getVisible
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    setVisible
 * Signature: (Z)V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_setVisible
  (JNIEnv *, jobject, jboolean);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    waitForLoadToComplete
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_waitForLoadToComplete
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    startComNatively
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_startComNatively
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    openIe
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_openIe
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    deleteStoredObject
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_deleteStoredObject
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    setFrameIndex
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_setFrameIndex
  (JNIEnv *, jobject, jstring);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    goBack
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_goBack
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    goForward
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_goForward
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    doAddCookie
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_doAddCookie
  (JNIEnv *, jobject, jstring);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    doGetCookies
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_doGetCookies
  (JNIEnv *, jobject);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    doSetMouseSpeed
 * Signature: (I)V
 */
JNIEXPORT void JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_doSetMouseSpeed
  (JNIEnv *, jobject, jint);

/*
 * Class:     org_openqa_selenium_ie_InternetExplorerDriver
 * Method:    doSwitchToActiveElement
 * Signature: ()Lorg/openqa/selenium/WebElement;
 */
JNIEXPORT jobject JNICALL Java_org_openqa_selenium_ie_InternetExplorerDriver_doSwitchToActiveElement
  (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif
#endif
