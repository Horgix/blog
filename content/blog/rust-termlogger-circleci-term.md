+++
type = "post"
author = "Horgix"
date = "2019-06-24"
title = "Rust, CircleCI and terminal logging - A story of CLI debugging"
description = "Got a CLI in Rust using simplelog/TermLogger that failed to run in CircleCI. Let's see together why and how to avoid this!"
categories = ["rust", "circleci", "ci", "terminal", "debug"]
+++

- [Rust, TermLogger and CircleCI - A story of CLI debugging](#rust--termlogger-and-circleci---a-story-of-cli-debugging)
    * [When the failures starts](#when-the-failures-starts)
    * [Reminder: `Option::unwrap()`](#reminder---option--unwrap---)
    * [Hunting for `.unwrap()`](#hunting-for--unwrap---)
    * [Treating Error cases properly to get more informations](#treating-error-cases-properly-to-get-more-informations)
    * [Where everything unfolds](#where-everything-unfolds)
    * [CircleCI and terminal allocation](#circleci-and-terminal-allocation)
    * [Fixing](#fixing)
    * [Take away](#take-away)

# Rust, TermLogger and CircleCI - A story of CLI debugging

For a few weeks now I've been **playing with [Rust](https://www.rust-lang.org/)
to create a command line tool**. Let's call it `my-cli`. For the record, I'm
using the famous [**clap**](https://github.com/clap-rs/clap) library for all
the CLI arguments handling (doesn't really matter for the reste of this article
though).

I'm building, testing and packaging `my-cli` on
[**CircleCI**](https://circleci.com/).

Obviously, at some point (early), I needed to **log things**. I ended up
choosing [`simplelog`](https://crates.io/crates/simplelog) as the logging
implementation compatible with the [`log`](https://crates.io/crates/log)
facade. **I mainly chose it for its `TermLogger`** described as an _"advanced
terminal logger, that splits to stderr/out and has color support"_. Totally
suited for a CLI app!

_Keep in mind I'm still learning a ton about Rust so things might seem obvious
to you but they weren't to me at that point :)_

## When the failures starts

At some point, the **CircleCI job started to fail**. Too bad for me, _we didn't
keep enough history to be able to pin point the commit that introduced this
fail_.

Anyway, here is what the pipeline looked like:

![Screenshot - CircleCI pipeline](https://horgix-public-blog-images.s3.fr-par.scw.cloud/screenshot-circleci-pipeline.png)

The pipeline builds the CLI, then **run it locally with the `--help` option as
a really really minimal functionnal smoke test**. I also have a real but
minimal test suite with unit tests that I'm only running locally for now. Yes,
this is definitely not enough. Keep in mind I'm only a few hours into this.

Essentially, the _"Smoke test"_ step is the following one:

```
"Smoke test":
  docker:
    - image: circleci/rust:1.33.0
  steps:
    - attach_workspace:
        at: .
    - run:
        name: "Execute binary with --help"
        command: ./my-cli --help
    - run:
        name: "Execute binary with --help and check that output looks ok-ish"
        command: ./my-cli --help | head -n1 | grep my-cli
```

Back to our topic: why does it fails to run? Everything seems to compile and
run fine in my IDE. I even downloaded the binary stored as artifact by CircleCI
and ran it locally on my laptop without any problem. Here is the precise
failure:

![Screenshot - CircleCI failure](https://horgix-public-blog-images.s3.fr-par.scw.cloud/screenshot-circleci-failure.png)

```
#!/bin/bash -eo pipefail
./my-cli --help

thread 'main' panicked at 'called `Option::unwrap()` on a `None` value', src/libcore/option.rs:345:21
note: Run with `RUST_BACKTRACE=1` environment variable to display a backtrace.
Exited with code 101
```

So I ended up adding the said `RUST_BACKTRACE` environment variable in order to
have more insights about what the f\*\*\* was going on. And here it is:

```
#!/bin/bash -eo pipefail
./my-cli --help

thread 'main' panicked at 'called `Option::unwrap()` on a `None` value', src/libcore/option.rs:345:21
stack backtrace:
   0: std::sys::unix::backtrace::tracing::imp::unwind_backtrace
             at src/libstd/sys/unix/backtrace/tracing/gcc_s.rs:39
   1: std::sys_common::backtrace::_print
             at src/libstd/sys_common/backtrace.rs:70
   2: std::panicking::default_hook::{{closure}}
             at src/libstd/sys_common/backtrace.rs:58
             at src/libstd/panicking.rs:200
   3: std::panicking::default_hook
             at src/libstd/panicking.rs:215
   4: std::panicking::rust_panic_with_hook
             at src/libstd/panicking.rs:478
   5: std::panicking::continue_panic_fmt
             at src/libstd/panicking.rs:385
   6: rust_begin_unwind
             at src/libstd/panicking.rs:312
   7: core::panicking::panic_fmt
             at src/libcore/panicking.rs:85
   8: core::panicking::panic
             at src/libcore/panicking.rs:49
   9: my_cli::main
  10: std::rt::lang_start::{{closure}}
  11: std::panicking::try::do_call
             at src/libstd/rt.rs:49
             at src/libstd/panicking.rs:297
  12: __rust_maybe_catch_panic
             at src/libpanic_unwind/lib.rs:92
  13: std::rt::lang_start_internal
             at src/libstd/panicking.rs:276
             at src/libstd/panic.rs:388
             at src/libstd/rt.rs:48
  14: main
  15: __libc_start_main
  16: _start
Exited with code 101
```

Not that much more helpful. No mention of my own code except `9: my_cli::main`.

However, it seems related to some `Option::unwrap()` call so let's find the
culprit!

## Reminder: `Option::unwrap()`

[`Option::unwrap()`](https://doc.rust-lang.org/std/option/enum.Option.html#method.unwrap)
is used to extract a value v from an Option type. The doc states it better than
I do:

![Screenshot - Option::unwrap doc](https://horgix-public-blog-images.s3.fr-par.scw.cloud/screenshot-unwrap-doc.png)

Note that it explicitely discourage what I was doing:

> In general, because this function may panic, its use is discouraged. Instead,
> prefer to use pattern matching and handle the None case explicitly.

This is what seems to happen.

_Note_: the [first version of the Rust
Book](https://doc.rust-lang.org/1.30.0/book/first-edition/error-handling.html#unwrapping-explained)
explains unwrapping with more details if you want to know more.

## Hunting for `.unwrap()`

I began a hunt of every `.unwrap()` that was in the code (bare with me, there
were 3 of them). It was a good opportunity to force myself to handle errors
better, which I (wrongly) postponed for a while - now it the time to treat it!

One of these calls was this one:

```rust
    CombinedLogger::init(vec![
        TermLogger::new(LevelFilter::Debug, Config::default()).unwrap()
    ]).unwrap();
```

This is the **logger initialization from `simplelog`**. I initially didn't
handled the error case properly and just called `unwrap()` because _what could
go wrong about the initialization of a logging structure with default
settings?_

And indeed, as someone pointed out [on
StackOverflow](https://stackoverflow.com/a/48862478), the `TermLogger`
documentation doesn't even mention why it could ends up returning `None`:

> The documentation of TermLogger::new is not good, because it does not explain
> why it returns an Option.

## Treating Error cases properly to get more informations

To confirm this was the call causing the failure, I handled the case as I
should have from the beginning:

```rust
let term_logger = match TermLogger::new(LevelFilter::Debug, Config::default()) {
    Some(tl) => tl,
    None => {
        println!("Failed to create TermLogger; exiting.");
        std::process::exit(1);
    }
};
CombinedLogger::init(vec![termlogger]).expect("Failed to initialize logger");
```

And sure enough, after treating the error properly, I finally got more insight
from my CI run:

```
./my-cli --help

Failed to create TermLogger; exiting.
Exited with code 1
```

## Where everything unfolds

So, why is my `TermLogger::new()` failing on the CI while it's running perfectly
fine on my machine?

Let's unwrap how the calls are going (yes, I just did this joke) and dig to see
why and how `TermLogger::new()` could return `None`:

-  [`TermLogger::new`](https://github.com/Drakulix/simplelog.rs/blob/master/src/loggers/termlog.rs#L144)
   mainly calls the [`term`
library](https://stebalien.github.io/doc/term/term/index.html). It does so with `term::stdout()` and `term::stderr()`.
- [`term::stdout()`](https://github.com/Stebalien/term/blob/67a1d78a8cacc1657137433c16ec31715407de90/src/lib.rs#L92)
  and
  [`term::stderr()`](https://github.com/Stebalien/term/blob/67a1d78a8cacc1657137433c16ec31715407de90/src/lib.rs#L112)
  are only wrapper around [the `Terminfo::new()`
  function](https://github.com/Stebalien/term/blob/67a1d78a8cacc1657137433c16ec31715407de90/src/terminfo/mod.rs#L384_)
- ... which
  [calls](https://github.com/Stebalien/term/blob/67a1d78a8cacc1657137433c16ec31715407de90/src/terminfo/mod.rs#L385)
  [`TermInfo::from_env`](https://github.com/Stebalien/term/blob/67a1d78a8cacc1657137433c16ec31715407de90/src/terminfo/mod.rs#L63)

And this is where things gets interesting. Here is the [first line of
`TermInfo::from_env`](https://github.com/Stebalien/term/blob/67a1d78a8cacc1657137433c16ec31715407de90/src/terminfo/mod.rs#L64)
:

    let term_var = env::var("TERM").ok();

So, **this looks like it could be where things are failing**.

Reproducing locally is easy: just `unset TERM`, run the binary and here we go,
I have the same crash than on my CI pipeline.

This behavior is definitely understandable from the `term` crate, since it
needs the [terminfo](http://tldp.org/HOWTO/Text-Terminal-HOWTO-16.html) at some
point to know what your terminal capabilities are (see `man 5 terminfo` for
more).

## CircleCI and terminal allocation

Surprisingly, I never had any problem or varying behavior when running stuff on
CircleCI compared to any other environment; even though I'm using the [Docker
executor](https://circleci.com/docs/2.0/executor-types/#using-docker).

CircleCI is indeed allocating a TTY so everything should be right.

However, as we guessed from earlier results, **CircleCI doesn't export a `TERM`
environment variable** (confirmed by [a post on their
forums](https://discuss.circleci.com/t/circleci-terminal-is-a-tty-but-term-is-not-set/9965))
which causes this failure to initialize `TermInfo`.

## Fixing

The fix was quite easy; just add the `TERM` environment variable to the
environment of my smoke test:

```
"Smoke test":
  docker:
    - image: circleci/rust:1.33.0
  environment:
    TERM: xterm
  steps:
    - attach_workspace:
        at: .
    - run:
        name: "Execute binary with --help"
        command: ./my-cli --help
    - run:
        name: "Execute binary with --help and check that output looks ok-ish"
        command: ./my-cli --help | head -n1 | grep my-cli
```

However, **fixing things for myself is not the only thing to do here**. Other
may (and, from a couple of StackOverflow threads, already do) encounter the
same problem than me and wonder why `TermLogger::new()` is failing; so **let's
improve this for everyone!**

TODO/WIP:

- PR doc of TermLogger
- Return Error with appropriate message in `simplelog` or `term`?

## Take away

What you should remember after reading this article:

- **Never `.unwrap()` !** At the bare minimum, `.expect()` to have an
  appropriate message and make your debugging easier. Ideally, handle error
  cases cleanly: match for your `Err` and `None` and treat it appropriately.
- The documentation for the `None` case of the TermLogger of simplelog could be
  improved.
- Be warry of CI environments, they can be *slightly* different than what you
  think they are :)
- Keep in mind that **CircleCI doesn't export a `TERM` environment variable**


Hope this really focused piece of debugging might help someone at some point.
