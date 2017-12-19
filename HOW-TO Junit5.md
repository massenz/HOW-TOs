## HOW-TO Use JUnit 5 and Spring

Notes from [JUnit 5 video at SpringOne](https://www.youtube.com/watch?v=h0Idcz71Aog).
See examples [here](https://github.com/sbrannen/junit5-demo).

Typical usage, mostly for IDEs, etc.:

```
@RunWith(JunitPlatform.class)
```

# Components

- Junit Platform 1.0.0 -- Launcher & Frameworks
- JUnit Jupiter 5.0.0 -- testing model
- JUnit Vintage -- support for JUnit 3/4

# TestEngine API

- discovers / executes tests;
- `JupiterTestEngine` for the new testing framework
- support for Java 9 Modules

# Extension Model

`@ExtendWith( ... )`  class, method or interface level
Lifecycle Callbacks - Before/After all/each/test callback

`org.junit.jupiter.api` -- base package

Can have

- tags
- conditional test execution
- dependency injection
- etc.

# Available annotations:

```
@Test
@RepeatedTest
@Nested
@TestInstance
@BeforeAll/AfterAll
@BeforeEach/AfterEach

@DisplayName
@Tag
@Disabled
```

# Assumptions

`org.junit.jupiter.api.Assumptions` to abort a test mid-flight, if any of
the assumptions is not satisfied.

- `assumeTrue() / assumeFalse()`
- `assumingThat( <condition>, () -> {})` to conditionally execute a lambda function


`@Disabled` takes a `DisabledCondition` to programmatically enable/disable tests.
(also defined things like `@DisabledOnMac`)

`TestInfo` can be "injected" into a test method:

```
@Test
@DisplayName("The awesome test!")
void awesomeTest(TestInfo testInfo) {
    // Your tests here
    System.err.println(testInfo);
}
```

# Dynamic Tests

Use `@TestFactory` and return a `Stream<DynamicTest>`.

# Spring Support

`@SpringJunitConfig(TestConfig.class)` will support `@Autowired` in constructor
and class fields; also in test methods' arguments:

```
@Test
void testCats(@Autowired List<Cat> cats) {
    assertEquals(2, cats.size());
}
```

and `@Qualifier()` annotation (including SpEL expressions
