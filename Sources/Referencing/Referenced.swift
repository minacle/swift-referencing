import Locks

#if canImport(Combine)
import Combine
#endif

/// A property wrapper type that encapsulates a value as a reference
/// type, allowing them to be read and written in a safe way.
///
/// `Referenced` allows you to treat a value type like a reference
/// type. This can be useful when you want to have a single copy of a
/// value that is shared across multiple parts of your codebase, or
/// when you need to mutate a value type in a way that you can observe
/// the changes to the value.
///
/// If your app targets Apple platforms, `Referenced` works with
/// Combine to provide notifications when the value changes. For
/// example, you can use `objectWillChange` publisher to trigger
/// updates in SwiftUI views when the value changes.
///
/// Note that `Referenced` is thread-safe by default, meaning that you
/// can safely use it from multiple threads without causing data races.
/// To achieve this, `Referenced` internally uses a read-write lock to
/// synchronize access to its value. However, keep in mind that using
/// `Referenced` in this way may introduce additional overhead, and may
/// not be necessary in all cases.
///
@propertyWrapper
public final class Referenced<Value> {

    /// The read-write lock used to protect the wrapped value.
    ///
    @usableFromInline
    internal let _lock: ReadWriteLock = .init()

    /// The pointer to the wrapped value.
    ///
    @usableFromInline
    internal let _storage: UnsafeMutablePointer<Value>

    /// Creates a referenced type with the given wrapped value.
    ///
    /// This initialiser is provided for convenience when you're not
    /// using `@Referenced` attribute.
    ///
    /// - Parameters:
    ///   - value:
    ///     An initial value.
    ///
    @inlinable
    public init(_ value: Value) {
        _storage = .allocate(capacity: 1)
        _storage.initialize(to: value)
    }

    ///
    deinit {
        _storage.deallocate()
    }

    // MARK: @propertyWrapper

    /// The underlying value referenced by the `Referenced` instance.
    ///
    /// This value is protected by a read-write lock, allowing safe
    /// access from multiple threads for both read and write
    /// operations.
    ///
    @inlinable
    public var wrappedValue: Value {
        @inline(__always)
        _read {
            _lock.lock(to: .read)
            defer {
                _lock.unlock()
            }
            yield _storage.pointee
        }
        @inline(__always)
        _modify {
            _lock.lock(to: .write)
            defer {
                _lock.unlock()
            }
#if canImport(Combine)
            objectWillChange.send()
#endif
            yield &_storage.pointee
        }
    }

    /// Creates a referenced type with an initial wrapped value.
    ///
    /// Directly calling this method is discouraged. Instead, declare a
    /// property with the `@Referenced` attribute, and provide an
    /// initial value.
    ///
    /// - Parameters:
    ///   - wrappedValue:
    ///     An initial value.
    ///
    @inlinable
    public convenience init(wrappedValue: Value) {
        self.init(wrappedValue)
    }
}

extension Referenced: CustomReflectable {

    @inlinable
    public var customMirror: Mirror {
        .init(self, children: ["value": wrappedValue])
    }
}

extension Referenced: CustomStringConvertible {

    @inlinable
    public var description: String {
        "\(Self.self)(\(String(reflecting: wrappedValue)))"
    }
}

#if canImport(Combine)
extension Referenced: ObservableObject {
}
#endif

#if canImport(_Concurrency)
extension Referenced: Sendable {
}
#endif

// MARK: -

extension Referenced: Comparable
where Value: Comparable {

    // MARK: Comparable

    @_transparent
    @inlinable
    public static func < (lhs: Referenced, rhs: Referenced) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }

    @_transparent
    @inlinable
    public static func <= (lhs: Referenced, rhs: Referenced) -> Bool {
        lhs.wrappedValue <= rhs.wrappedValue
    }

    @_transparent
    @inlinable
    public static func > (lhs: Referenced, rhs: Referenced) -> Bool {
        lhs.wrappedValue > rhs.wrappedValue
    }

    @_transparent
    @inlinable
    public static func >= (lhs: Referenced, rhs: Referenced) -> Bool {
        lhs.wrappedValue >= rhs.wrappedValue
    }
}

extension Referenced: Decodable
where Value: Decodable {

    // MARK: Decodable

    @inlinable
    public convenience init(from decoder: Decoder) throws {
        try self.init(.init(from: decoder))
    }
}

extension Referenced: Encodable
where Value: Encodable {

    // MARK: Encodable

    @inlinable
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Referenced: Equatable
where Value: Equatable {

    // MARK: Equatable

    @_transparent
    @inlinable
    public static func == (lhs: Referenced, rhs: Referenced) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Referenced: Hashable
where Value: Hashable {

    // MARK: Hashable

    @inlinable
    public var hashValue: Int {
        wrappedValue.hashValue
    }

    @inlinable
    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

extension Referenced: Identifiable
where Value: Identifiable {

    // MARK: Identifiable

    @inlinable
    public var id: Value.ID {
        wrappedValue.id
    }
}
