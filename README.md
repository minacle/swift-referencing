# swift-referencing

`swift-referencing` is a lightweight library that provides a `Referenced` property wrapper for encapsulating a value as a reference type in Swift.

## Usage

To use `Referencing` module in your project, you can simply add it as a dependency in your  `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/minacle/swift-referencing", from: "1.0.0"),
],
targets: [
    .target(
        name: "MyTarget",
        dependencies: [
            .product(name: "Referencing", package: "swift-referencing"),
        ]
    ),
]
```

After adding the dependency, you can import the `Referencing` module in your Swift code:

```swift
import Referencing
```

Then you can use the `@Referenced` attribute to mark any property as a referenced type.

```swift
@Referenced var value: Int = 42
```

You can then read and write the value as if it were a regular property:

```swift
print(value) // Output: 42
value = 23
print(value) // Output: 23
```

`Referenced` is thread-safe by default, meaning that you can safely use it from multiple threads without causing data races. To achieve this, `Referenced` internally uses a read-write lock to synchronize access to its value.

If your app targets Apple platforms, `Referenced` works with Combine to provide notifications when the value changes. For example, you can use `objectWillChange` publisher to trigger updates in SwiftUI views when the value changes.

## License

`swift-referencing` is released under the [Unlicense](https://unlicense.org).
