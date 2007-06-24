/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_thoughtworks_webdriver_ie_InternetExplorerElement */

#ifndef _Included_com_thoughtworks_webdriver_ie_InternetExplorerElement
#define _Included_com_thoughtworks_webdriver_ie_InternetExplorerElement
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    createInternetExplorerElement
 * Signature: (JLcom/thoughtworks/webdriver/ie/ElementNode;)Lcom/thoughtworks/webdriver/ie/InternetExplorerElement;
 */
JNIEXPORT jobject JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_createInternetExplorerElement
  (JNIEnv *, jclass, jlong, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    click
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_click
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    getAttribute
 * Signature: (Ljava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_getAttribute
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    getText
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_getText
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    getValue
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_getValue
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    setValue
 * Signature: (Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_setValue
  (JNIEnv *, jobject, jstring);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    isEnabled
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_isEnabled
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    isSelected
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_isSelected
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    setSelected
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_setSelected
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    submit
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_submit
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    toggle
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_toggle
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    deleteStoredObject
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_deleteStoredObject
  (JNIEnv *, jobject);

/*
 * Class:     com_thoughtworks_webdriver_ie_InternetExplorerElement
 * Method:    getChildrenOfTypeNatively
 * Signature: (Ljava/util/List;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_com_thoughtworks_webdriver_ie_InternetExplorerElement_getChildrenOfTypeNatively
  (JNIEnv *, jobject, jobject, jstring);

#ifdef __cplusplus
}
#endif
#endif