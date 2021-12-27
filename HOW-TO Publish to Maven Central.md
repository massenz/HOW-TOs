


# Publishing to Maven Central

*Created by M. Massenzio, 2021-12-26*

## Motivation

Publishing one's own source code under an Open Source license (Apache 2 being my favorite one) and making the code publicly available on GitHub is only half the story, these days, in ensuring that your open source project will reach a wide audience.

A critical part is also packaging it in a way that is convenient for users to adopt it, and low effort to maintain and upgrade with new releases, which may include new features and bug fixes.

When it comes to Java, the obvious choice is to use [Maven Central](https://mvnrepository.com/repos/central) and allow folks to use something like:

```groovy
implementation 'com.alertavert:jwt-opa:0.6.4.4'
```

in their Gradle build (and similarly from their `pom.xml`).

It turns out that publishing to Maven is not as straightforward as one would hope, and a lot of the information out there is either incomplete, outdated or straight out incorrect.

This post summarizes a two-day effort in putting together the pieces that make up the puzzle (mostly by trial and error) and which resulted in my successfully publishing my [Spring Security / Open Policy Agent](https://github.com/massenz/jwt-opa) project [to Maven Central](https://mvnrepository.com/artifact/com.alertavert/jwt-opa).


## Fully worked example

The complete `build.gradle` is available [here](https://github.com/massenz/jwt-opa/blob/main/jwt-opa/build.gradle#L73): I will only reference snippets here, please see the repository for the complete details.


## The preliminaries - registering with Sonatype

You can't actually push your JARs, however well-intentioned, directly to Maven Central: you need instead to register and upload with artifact repositories (such as Sonatype's) which then regularly sync with Maven and will "release" your artifacts.

Before you can do anything at all, you need to register with [Sonatype Jira](https://issues.sonatype.org/secure/Signup!default.jspa) and create a ticket, such as this [Example Issue](https://issues.sonatype.org/browse/OSSRH-76600).

**Make sure you keep safe your username/password for the Sonatype registration, as you will need it later.**

Luckily the process is fully automated, and it only takes an hour or so (including the necessary delay introduces by having to get DNS involved in the process).

In fact, if you are registering a "reverse domain" (such as `com.alertavert`) you will need to prove ownership of the domain (which makes sense, otherwise anyone could post some `com.apple` or `com.google` random, or worse, malicious artifact).

In particular, you will need to create a TXT Record (use `@` as the `Host` part) with your domain registrar, which includes the Jira ticket reference:

```
└─( host -t txt alertavert.com
alertavert.com descriptive text "OSSRH-76600"
```

## Creating a GPG Key

All the uploaded code needs to be signed by you as the author, and will be validated both during upload and release.

This is done using a GPG key pair, that you will need to create, before publishing the artifact; if you are not familiar with the process [GitHub has a series of articles on GPG Keys](https://docs.github.com/en/authentication/managing-commit-signature-verification) or you are welcome to just peruse my [condensed version](https://codetrips.com/2021/12/25/how-to-make-verified-github-commits/).

Once you have created the key, you need to post it to public servers (I have used `keyserver.ubuntu.com`, there are several others) and also export the secret key someplace for the signing plugin to load it from:

    # The `signing` plugin uses short IDs; this is the magic
    # incantation to find the `keyId`:
    gpg --list-signatures --keyid-format 0xshort

    # Using the full Key ID, post it to a GPG Key Server:
    gpg --keyserver keyserver.ubuntu.com --send-keys DF4C...E372

    # Export the key someplace where it can be picked up by the
    # signing plugin:
    gpg --export-secret-keys you@example.com > /path/to/your/exported.gpg


You can store all the relevant details in your **private** `~/.gradle/gradle.properties` (these are global settings; if you need to use different settings with different projects, you can add those in each project's top-level folder) whatever you do, **make sure to never add these to your git files**:

```python
#### DO NOT EVER ADD THIS FILE TO THE PUBLIC REPO ######

ossrhUsername=<<Sonatype username>>
ossrhPassword=<<Sonatype password>>

# In all cases, we need to use the values from the `pub` key.
signing.keyId=<<that 0x123...ABC short code>>
signing.password=<<GPG passphrase goes here>>
signing.secretKeyRingFile=/path/to/your/exported.gpg
```

All this was just the warmup, you still haven't gotten one inch closer to publishing your artifact.


## Defining the `publication` that will be published

The Sonatype Jira issue will also point you helpfully to [some documentation](https://central.sonatype.org/publish/publish-gradle/) showing you what your `build.gradle` should look like.

In my experience, **this does not work**, you have been warned.

I found instead, the [Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html) documentation more useful, even though it was more a set of "tantalizing hints" rather than a fully-fledged explanation of how it all hangs together.

It is important to note that **if your published artifact does not have javadoc and sources, Sonatype will fail the release**, so it is important that you include both (hilariously, you only find out **much** later, at the end of this laborious process -- on the bright side, the errors on the Sonatype Manager are pretty explicit in that respect).

This is rather easy to do (but no one will say so straight out) with:

```groovy
java {
    withJavadocJar()
    withSourcesJar()
}
```

and, in the `publication` section you need to add these to the generated Jar in the `artifacts` list (in a second, more about that `shadowJar` thing):

```groovy
publishing {
    publications {
        jwtopaLibrary(MavenPublication) {
            artifactId = 'jwt-opa'
            artifacts = [ shadowJar, javadocJar, sourcesJar ]
            pom {
                // more stuff, a lot more stuff, goes there
                // ...
            }
        }
    }
}
```

One note here about Gradle (and Groovy syntax in particular): I really like it, but only because the alternative is Maven and XML - which is like to say that you enjoy sand in your hair, because it's better than having to lick it.

Getting any part of the `publications` object configuration even slightly incorrect generates error messages that are totally unhelpful: the good news is that every part is optional, so you can selectively add/remove parts (starting, like I did, eventually, in despair, with an empty pair of braces) and isolate the section that somehow doesn't work.

The one that is in the `jwt-opa` code is correct and works, and you are welcome to copy, paste and modify it as appropriate - but beware, even so it may be frustratingly cumbersome to get Gradle to like you.

Having said that, the only two things that matter in all that stuff are the `artifacts` (we spoke about them) and the `jwtopaLibrary` object - this can be called anything you want; the plugin will create an object of type `MavenPublication` named thus, which you can then pass on to the `signing` plugin:

```groovy
signing {
    sign publishing.publications.jwtopaLibrary
}
```

This is where all that jazz around the GPG key and `gradle.properties` kicks in.

### Building a "fat" Jar

By default, Spring Boot Jar plugin will only package the project's classes, leaving out all Spring dependencies: this generally works well (and prevents your Jar from becoming, well, obese) but may cause issues downstream with your library users, as they may need to specify those dependencies themselves.

This is particularly annoying when using Spring Boot, as the `bootJar` task would take care of the packaging, but it can't be used for a library, as the "main class" is missing, but it disables generation of a "regular" Jar.

There may be other ways around this, but this is how I solved this particular riddle:

- disable `bootJar` generation;
- add the [Shadow JAR Plugin](https://imperceptiblethoughts.com/shadow/introduction/);
- build a `shadowJar` and upload that one instead, making sure to remove the `-all` suffix.

In other words:

```groovy
bootJar.enabled = false
jar.enabled = true
jar.dependsOn shadowJar

shadowJar {
    archiveClassifier.set('')
}

# In the `publications` section use shadowJar
artifacts = [ shadowJar, ... ]
```

Possibly not the most elegant/effective solution, but it works (and saves your dependent projects the pain of having to figure out transitive dependencies).


## Defining the destination Repository

Finally, you want to define **where** the artifacts should be uploaded, using the [Repository Definition](https://docs.gradle.org/current/dsl/org.gradle.api.artifacts.repositories.MavenArtifactRepository.html).

In particular:

```groovy
repositories {
    sonatype {
        url "${os1_url}"
        credentials {
            username = "${ossrhUsername}"
            password = "${ossrhPassword}"
        }
    }
}
```

The `os1_url` is the Sonatype artifacts repository `https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/`.


## Publishing to Sonatype

Before trying to publish to Sonatype, it is advisable to confirm that all the machinery above works as intended (starting from Gradle accepting your build script).

I found that these steps were helpful in figuring out whether I was heading down the right path:

1. `./gradlew clean build -x test`<br/>
  quick and dirty way to see if the artifacts were generated correctly, with the relative signatures: you can go look into `./<sub-module>/build/libs/` dir and confirms that the "fat" Jar and the `sources` and `javadoc` Jars are there, along with the relative three `*.asc` signatures;

2. `./gradlew publishToMavenLocal`<br/>
  which would publish your Jar(s) to the local Maven repository (typically, in `~/.m2/repository/`, unless you've configured it to be somewhere else)

In the case of my `com.alertavert:jwt-opa:0.6.4.4` this is what it looks like:

```
└─( ls ~/.m2/repository/com/alertavert/jwt-opa/0.6.4.4/
jwt-opa-0.6.4.4.jar      jwt-opa-0.6.4.4-javadoc.jar      
jwt-opa-0.6.4.4.pom      jwt-opa-0.6.4.4-sources.jar
jwt-opa-0.6.4.4.jar.asc  jwt-opa-0.6.4.4-javadoc.jar.asc  
jwt-opa-0.6.4.4.pom.asc  jwt-opa-0.6.4.4-sources.jar.asc
```

No guarantee that this means it will all work, but until you get this step right, there is no chance that publishing to Maven will succeed either.

Alright, once this is done too, it's showtime!

`./gradlew publish`

if successful, will push your artifact to [Sonatype Repository Manager](https://s01.oss.sonatype.org/#stagingRepositories), where you will have to login and (manually) [Release on Sonatype your artifact](https://central.sonatype.org/publish/release/).

One word of warning: regardless of the seemingly "auto-updating" appearence, I found that the (adorable) Swing UI does **not** actually update when there are changes in the status: it does take some while for the backend to verify the signatures and validate the uploads, but you may want to refresh regularly (using the button on the top left) to check on progress.

Be that as it may, after a few minutes you will either see a positive validation (in which case, you can progress to "close" and "release" your artifact(s)) or whatever errors were encountered.


## Finally, result

Eventually, the contents on Sonatype repository will sync with Maven Central's and your library will be available for your users as a dependency:

```
implementation 'com.alertavert:jwt-opa:0.6.4.4'
```

I found that it takes some time to index it on [Maven Search](https://search.maven.org/artifact/com.alertavert/jwt-opa), so instead of obsessively refreshing that page (yes, I did that too), a much more sane approach is to have an actual Gradle project which depends on the library, comment out `mavenLocal()` in your `repositories` section, and just keep trying to build it, until it succeeds.

As mentioned, it has taken me several hours and many trials and errors to figure out all the above; here is to hoping this post helps you avoid the same tribulations, and if you have suggestions for how to improve the process, or simply found it useful, by all means, please feel free to drop a commment.

You can always find me on [my blog](http://codetrips.com) or on [GitHub](https://github.com/massenz), or on [LinkedIn](https://linkedin.com/in/mmassenzio).


### Links

[Sonatype Jira](https://issues.sonatype.org/secure/Signup!default.jspa)

[Example Issue](https://issues.sonatype.org/browse/OSSRH-76600)

[GitHub Series of articles on GPG Keys](https://docs.github.com/en/authentication/managing-commit-signature-verification)

[Code Trips condensed version](https://codetrips.com/2021/12/25/how-to-make-verified-github-commits/)

[Sonatype Repository Manager](https://s01.oss.sonatype.org/#stagingRepositories)

[Releasing Sonatype artifact](https://central.sonatype.org/publish/release/)

[Publishing Sonatype artifact (**do not use**)](https://central.sonatype.org/publish/publish-gradle/)

[jwt-opa Maven Repository](https://search.maven.org/artifact/com.alertavert/jwt-opa)

[Javadoc Plugin](https://docs.gradle.org/current/dsl/org.gradle.api.tasks.javadoc.Javadoc.html)

[Maven Publish Plugin](https://docs.gradle.org/current/userguide/publishing_maven.html)

[Repository Definition (Gradle)](https://docs.gradle.org/current/dsl/org.gradle.api.artifacts.repositories.MavenArtifactRepository.html)

[Gradle Signing Plugin](https://docs.gradle.org/current/userguide/signing_plugin.html#signing_plugin)

[Shadow JAR Plugin](https://imperceptiblethoughts.com/shadow/introduction/)

[Gradle Nexus plugin](https://github.com/gradle-nexus/publish-plugin/)
