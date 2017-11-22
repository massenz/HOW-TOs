# Java 9

[This video](https://www.youtube.com/watch?v=MGX-JfMl9-Y) is a simple introduction to the new Module System (aka `Jigsaw`) in Java 9.

There is also a new `Module` class, and modules can be introspected, just like classes do:

    java.lang.Module
    class.getModule()

There are 26 base modules; guaranteed to have **No Cycles** (and creating modules that have cycles *will* cause compile errors).

`java.base` is always there (implicitly `required`).

The actual JDK has 75 modules (most of the other are in the `jdk.` namespace).

JDK modules are packaged as `jmod` files, which contain more stuff than JAR files (such as native code, DLLs, etc.)

## JLink

To package a subset of modules, to make a more compact image (e.g., to use in Docker images):

    $ jlink --module-path ${JAVA_HOME}/jmods --output jre --add-modules java.base

will create a package that is 43MB in size (as opposed to the 340MB+ for the full JDK image).

You can package your own application and even create a launcher, while also compressing and making it even smaller:

    $ jlink --module-path lib:${JAVA_HOME}/jmods \
        --output my-app \
        --add-modules org.openjdk.hello \
        --strip-debug \
        --compress 2 \
        --launcher hello=org.openjdk.hello

(see below for how to build the `hello` module).

# Simple example

See the `java9` project and the `jj` script for details.

## Create a separate module and "import" it


The library module:

    module org.openjdk.text {
        export org.openjdk.text;
    }

imported by the application module:

    module org.openjdk.hello {
        requires org.openjkd.text;
    }

### Describe the module

    $ jar --file lib/org-openjdk-hello.jar --describe-module

# Running both JDK 8 and 9 on Ubuntu

Following [this guide](http://www.webupd8.org/2015/02/install-oracle-java-9-in-ubuntu-linux.html):

    $ sudo add-apt-repository ppa:webupd8team/java

    $ sudo apt-get update && sudo apt-get upgrade -y

    $ update-java-alternatives --list
    java-8-oracle                  1081       /usr/lib/jvm/java-8-oracle
    java-9-oracle                  1091       /usr/lib/jvm/java-9-oracle

    $ java -version
    java version "1.8.0_151"
    Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
    Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode)


To [switch between versions](https://askubuntu.com/questions/740757/switch-between-multiple-java-versions):

    $ sudo update-alternatives --config java

## Manually setting `java`

Use the `update-alternatives` command (see `sudo update-alternatives --help`):

    $ which java
    /usr/bin/java

    $ java -version
    java version "9.0.1"
    Java(TM) SE Runtime Environment (build 9.0.1+11)
    Java HotSpot(TM) 64-Bit Server VM (build 9.0.1+11, mixed mode)

    $ sudo update-alternatives --list java
    /usr/lib/jvm/java-8-oracle/jre/bin/java
    /usr/lib/jvm/java-9-oracle/bin/java

    $ sudo update-alternatives --set java /usr/lib/jvm/java-8-oracle/jre/bin/java
    update-alternatives: using /usr/lib/jvm/java-8-oracle/jre/bin/java to provide /usr/bin/java (java) in manual mode

    $ java -version
    java version "1.8.0_151"
    Java(TM) SE Runtime Environment (build 1.8.0_151-b12)
    Java HotSpot(TM) 64-Bit Server VM (build 25.151-b12, mixed mode)

# Migrating apps to Modules

Libraries imported (and not modularized) will be listed as their JAR filenames:

    module my.module {
        requires jackson.core;          // Will use the jackson-core-x.x.x.jar JAR
        requires jackson.databind;
        requires java.sql;              // A JDK 9 module
    }

to compile and inspect:

    $ javac -d mods --module-path lib --module-source-path src -m org.tweetsum
    $ javap mods/org.tweetsum/module-info.class

If our code needs to "expose" some classes for "deep reflection," we cannot simply `export` the package, we need to `open` it:

    module org.tweetsum {
        requires jackson.databind;
        ...
        // The `to` qualifier may be omitted.
        opens org.tweetsum to jackson.databind;
    }

To get started migrating an app/library, use `jdeps` to generate an initial iteration of the `module-info.java` file:

    $ jdeps --generate-module-info src \
        lib/jackson-core-2.6.6.java

will write out `src/jackson.core/module-info.java`.
