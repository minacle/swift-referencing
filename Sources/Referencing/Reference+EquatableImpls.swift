@_transparent
@inlinable
public func == <T>(lhs: Referenced<T>?, rhs: Referenced<T>?) -> Bool
where T: Equatable {
    lhs?.wrappedValue == rhs?.wrappedValue
}

@_transparent
@inlinable
public func == <T>(lhs: Referenced<T?>?, rhs: Referenced<T>?) -> Bool
where T: Equatable {
    lhs?.wrappedValue == rhs?.wrappedValue
}

@_transparent
@inlinable
public func == <T>(lhs: Referenced<T>?, rhs: Referenced<T?>?) -> Bool
where T: Equatable {
    lhs?.wrappedValue == rhs?.wrappedValue
}
