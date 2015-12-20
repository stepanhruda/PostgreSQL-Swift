#if os(Linux)
import Glibc
#else
import Darwin
#endif

func floatFromInt32(input: Int32) -> Float {
    let array = byteArrayFrom(input)
    return typeFromByteArray(array, Float.self)
}

func doubleFromInt64(input: Int64) -> Double {
    let array = byteArrayFrom(input)
    return typeFromByteArray(array, Double.self)
}

func byteArrayFrom<T>(value: T) -> [UInt8] {
    var value = value
    return withUnsafePointer(&value) {
        Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>($0), count: sizeof(T)))
    }
}

func typeFromByteArray<T>(byteArray: [UInt8], _: T.Type) -> T {
    return byteArray.withUnsafeBufferPointer {
        return UnsafePointer<T>($0.baseAddress).memory
    }
}
