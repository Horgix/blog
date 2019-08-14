+++
type = "post"
author = "Horgix"
date = "2019-07-31"
title = "Kotlin and enum initialization"
description = "TODO"
categories = ["kotlin", "enum", "initialization", "code"]
+++

# Kotlin and enum initializatino

Today, we'll talk about blablabla

There will be a lot of cases and options considered in this post, with each its own code snippets example. All these example snippets are available in a [GitHub repository](TODO)

## Kotlin Enum Classes

In Kotlin, you can assign names to some constant values (usually referred as `enum` in most languages) through [Enum Classes](https://kotlinlang.org/docs/reference/enum-classes.html).

I'll let you take a look at [the Kotlin documentation about it](https://cloud.ibm.com/account/cloud-foundry/xebia/users) if you're not already familiar with Enum Classes.

Long story short, in Kotlin enums don't have to be limited to their identifier/name.

You can essentially define this:

```kotlin
enum class Color(val rgb: Int) {
        RED(0xFF0000),
        GREEN(0x00FF00),
        BLUE(0x0000FF)
}
```

And then access the `rgb` value for a given enum:

```kotlin
val alertColor: Color = Color.RED
println(alertColor.rgb)
```

Which is actually pretty convenient!

## Nitpicking on wording

TODO

## A concrete example

Let's take a more concrete and real case, with more informations than just an `Int` for each constant. Let's say we have the following `enum`:

```kotlin
enum class Format(val description: String, val duration: Int, val prefix: String) {
    LIGHTNING_TALK( "Lightning Talk (5min)",    5,      "lt"),
    FAST_TRACK(     "Fast Track (15min)",       15,     "fast"),
    CONFERENCE(     "Conférence (30min)",       30,     "conf"),
    HANDS_ON(       "Hands-On (2h)",            120,    "handson"),
    REX(            "REX (30min)",              30,     "rex")
}
```

It's really a nice way to represent constants and static details about something - in this case, some conference's talks formats!

## The big question : what about initialization/instantiation?

How would you go about instantiating a value of this `Format` type **from the description string**?

Let's say I have a description matching one from the enum `description` field, for example `REX(30min)`. How would I go about creating the corresponding `Format`, such as a `val myformat` that would have `Format.REX` as value?

```kotlin
val myInputDescription: String = "REX(30min)"
val myTalkFormat: Format = ??? // How to get Format from myInputDescription?
```

```kotlin
enum class MyEnum {
  Foo, Bar, Baz
}

fun main(args : Array<String>) {
  println(MyEnum.valueOf("Foo") == MyEnum.Foo)
  println(MyEnum.valueOf("Bar") == MyEnum.Bar)
  println(MyEnum.values().toList())
}
```

Can't do constructors.

```kotlin
enum class BitCount public constructor(val value : Int)
{
  x32(32),
  x64(64)
}
```

Wrong.

Let's consider one by one the options that might come to your mind when trying to implement this conversion/initialization.





### Option #1 - Use `valueOf()`

Nope.

```kotlin
enum class Format(val description: String, val duration: Int, val prefix: String) { //@formatter:off
    LIGHTNING_TALK( "Lightning Talk (5min)",    5,      "lt"),
    FAST_TRACK(     "Fast Track (15min)",       15,     "fast"),
    CONFERENCE(     "Conférence (30min)",       30,     "conf"),
    HANDS_ON(       "Hands-On (2h)",            120,    "handson"),
    REX(            "REX (30min)",              30,     "rex");
    //@formatter:on
}

fun main() {
    println("Option n°1 - Use valueOf()")
    val inputDescription = "Conférence (30min)"
    val mostRepresentedFormat: Format = Format.valueOf(inputDescription)
    println("Most represented talk format: ${mostRepresentedFormat.description}")
}
```

This will fail, since `valueOf()` tries to match on the constants **names** i.e `FAST_TRACK`, `CONFERENCE`, etc.

Calling it with a description as parameter will logically make it fail with an `IllegalArgumentException`:

```text
Option n°1 - Use valueOf()
Exception in thread "main" java.lang.IllegalArgumentException: No enum constant useValueOf.Format.Conférence (30min)
	at java.lang.Enum.valueOf(Enum.java:238)
	at useValueOf.Format.valueOf(main.kt)
	at useValueOf.MainKt.main(main.kt:15)
	at useValueOf.MainKt.main(main.kt)

Process finished with exit code 1
```

### Option #2 - Override `valueOf()`

Nope. Won't compile

Adding the `override` keyword won't change anything and will fail with `'valueOf' overrides nothing`
(TODO make this an entire option? Will depend on reasonning behind it)

### Option #3 - `valueOfDescription(...)`

Implement a `fun valueOfDescription(description: String): Format` function
outside

TODO why can't  we define it ON the enum itself by public final ?

Defining it externally is essentially more a `descriptionToFormat()` function than a `valueOfDescription` since it isn't apply on `Format`

### Option #4 - Map<String, Format>

FOrces a `!!` on the Map access

### Option #4 - Function extension

Here we go. Functions extensions are the _Kotlin way_ to solve many problems.

One might think...

Function extension

## Conclusion

What bother me is that

//    fun valueOfDescription(description: String) = when (description) {
//        LIGHTNING_TALK.description -> LIGHTNING_TALK
//        FAST_TRACK.description -> FAST_TRACK
//        CONFERENCE.description -> CONFERENCE
//        HANDS_ON.description -> HANDS_ON
//        REX.description -> REX
//        else -> throw Exception("")
//    }
}
fun valueOfDescription(description: String) = when (description) {
    Format.LIGHTNING_TALK.description -> Format.LIGHTNING_TALK
    Format.FAST_TRACK.description -> Format.FAST_TRACK
    Format.CONFERENCE.description -> Format.CONFERENCE
    Format.HANDS_ON.description -> Format.HANDS_ON
    Format.REX.description -> Format.REX
    else -> throw Exception("BOUH")
}
```

