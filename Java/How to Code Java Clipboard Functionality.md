# How to Code Java Clipboard Functionality

[Ref](https://www.developer.com/java/data/how-to-code-java-clipboard-functionality.html)

The Clipboard provides one of the most important functionalities of GUI, namely the cut-copy-paste functions. What we can do is select an element—be it a text segment, image, file, and so forth—from a user interface and trigger keyboard operations on the component that has input focus. Many of the user components provided by the Java GUI, such as Swing or AWT, have built-in support of this mechanism. This is the reason we do not need to explicitly hard code to implement this feature in every Java application. But, hard coding is necessary if we want to imbibe this feature into a custom user component developed in Swing, AWT, or JavaFX. This can be done with the help of the API support provided by Java. This article focuses into this API to give an idea how to implement it in Java code.

## Overview

The cut-copy-paste functionality simplifies data transfer between GUI components with the help of the resource called Clipboard. What usually happens is that when we issue a cut or copy command from a user component, the data is extracted to a global memory location managed by the underlying platform's Clipboard manager. It is for this reason that when we cut or copy a text from, say, a Swing textfield, it is also available to any other Java or non-Java application, say, the notepad. It may also be the case that the Java application from where the text is extracted has terminated, yet the data is available to another application through the paste command. This means that the global memory we are referring to is actually outside the periphery of the application from where it was extracted.

Java provides a dedicated class called Clipboard, defined in java.awt.datatransfer. The instance of this class is used to refer to the system resource called Clipboard. In most cases, however, direct instantiation of this class by using its sole constructor is not necessary because we can obtain a reference of it through the instance of another class, called Toolkit, defined in the java.awt package.

The Toolkit is an abstract superclass that comprises all the functionalities of the Abstract Window Toolkit and binds with the usability of native windowing toolkit implementations, such as the effect of scrolling, visibility of window, sizing, modality, and so on. Due to this, binding of the Abstract Window Toolkit with the native windowing makes the behavior of GUI distinct of the platform upon which the application runs.

The quickest way to get the reference of Clipboard is via Toolkit.

```java
JTextField textField=new JTextField(40);
Toolkit toolkit=textField.getToolkit();
```

Or, by using the static function defined in the Toolkit class.

```java
Toolkit toolkit=Toolkit.getDefaultToolkit();
```

Obtain the Clipboard reference as follows:

```java
Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
```
__System clipboard__

Clipboard, therefore, aids in smooth and simple data transfer between user components of various Java as well as non-Java applications. This simplicity of its usability is quite deceiving because data extracted through a cut-copy operation can be of various forms, such as a text segment, a rich document, an image, a file, a segment of picture element, and the like. The way the data is stored in the Clipboard has a strong imprint of the application it has been created with and is decisive on what other user component it can be pasted to. For example, some data extracted form a Excel sheet may be pasted to a similar application, but obviously cannot be pasted to a component that does not understand the format. In much the same way, a segment of a picture element extracted from a Photo editing application cannot be pasted to a simple text application like notepad. This means that when we extract data from an application, however simple it seems visibly, it also copies the formatting and other information about the data in the Clipboard. Adding to the problem, even the simple text data transfer is characterized by the numerous character sets. Data extracted form one application component may not agree with the character set supported by the destination component. Because Clipboard is managed by the underlying platform, it certainly has an advantage in this matter, but a Java application running on the higher layer may not be able to leverage native support in this regard.

Therefore, the bottom line is that when using a Clipboard resource, we should bear in mind that not all data can be transferred seamlessly, especially when we are dealing with Java and other native applications.

## The Clipboard Class

Now, let's see what the Clipboard class offers in terms of its functionality. The most common methods of this class are the setContents() and getContents(). The setContents() method is used to set contents to Clipboard, like cut-copy operations, and the getContents() method is used to retrieve the content from Clipboard, like the paste operation.

```java
void setContents(Transferable contents, ClipboardOwner owner)
Transferable getContents(Object requestor)
```

A data package to be set in the Clipboard must be wrapped in a `Transferable` object. The `Transferable` interface is defined in the java.awt.datatransfer package. It is primarily used as a means to provide data for the transfer operation. Therefore, every data package transferred to and from the Clipboard must be encapsulated in a `Transferable` instance. The data retrieved from the Clipboard with `getContents()` also receives a `Transferable` object.

The `ClipboardOwner`, also an interface defined in java.awt.datatransfer, refers to the owner of the contents of the Clipboard. This object is notified as soon as some other data overwrites the content of the Clipboard. Any content that is overwritten in the Clipboard means that the `ClipboardOwner` object has lost its ownership of that content.

While retrieving content from the Clipboard, care should be taken to check if the data flavor is supported by the receiving component where the data is intended to be pasted. Otherwise, a mismatch may result in throwing `UnsupportedFlavorException`.

## A Quick Example

Suppose we want to simulate the cut or copy operation (similar to pressing Ctrl+X or Ctrl+C) of a string value to the Clipboard and retrieve the value back from the Clipboard with the paste operation (Ctrl+V), we may do it as follows. As explained earlier, the format of the data or the data flavor plays a crucial role in the data transfer between components. Bear this in mind when experimenting with the following code that everything copied cannot be pasted everywhere. This is not the limitation of the Clipboard, but the limitation of the user components.

```java
package org.mano.example;

import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
   java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.StringSelection;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.IOException;

public class Main {

   public static void main(String[] args) {

      // This represents a cut-copy (Ctrl+X/Ctrl+C) operation.
      // The text will be copied to the clipboard
      // StringSelection is a Transferable implementation
      // class.

      StringSelection data = new StringSelection
         ("This is copied to the clipboard");
      Clipboard cb = Toolkit.getDefaultToolkit()
         .getSystemClipboard();
      cb.setContents(data, data);


      // This represents the paste (Ctrl+V) operation

      try {
         Transferable t = cb.getContents(null);
         if (t.isDataFlavorSupported(DataFlavor.stringFlavor))
            System.out.println(t.getTransferData(DataFlavor
               .stringFlavor));
      } catch (UnsupportedFlavorException | IOException ex) {
          System.out.println("");
      }
   }
}
```

## Conclusion

To keep is simple, this is all you need to begin implementation of Clipboard functionality in Java. The Clipboard class defines many other methods, but all centers around a few classes, such as DataFlavor, Transferable, and ClipboadOwner, and to implement data flavor events through the FlavorListeners event classes. Also, if you want to initiate Clipboard setContent and getContent method through keyboard events, consider implementing KeyStroke events in Java.

> References
> Java 8 API Documentation
> Spell, Brett. "Adding Cut-and-Paste Functionality." Pro Java 8 Programming. Berkeley: Apress, > 2015. 379-401. Print.
