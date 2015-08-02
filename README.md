

# MXPLib
A swift framework with various utilities and components

# Catalog

## `KeyedCallbacks`
A scoped callback management utility.

Usage:

```swift
import MXPLib

let keyedCallbacks = KeyedCallbacks<String>()

let handle1 = keyedCallbacks.register("key1") { print(">> \($0)") }

do {
    let handle2 = keyedCallbacks.register("key1") { print("## \($0)") }
    
    keyedCallbacks.performCallbacksForKey("key1", withParameters: "hello")
    // prints
    //
    //     >> hello
    //     ## hello
}

keyedCallbacks.performCallbacksForKey("key1", withParameters: "world")
// prints
//
//     >> world

```
