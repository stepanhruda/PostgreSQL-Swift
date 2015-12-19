#if os(Linux)
import Glibc
#else
import Darwin
#endif

func swapFloatBytes(input: Int32) -> Float {
    let swappedInt = swapInt32Bytes(input)
    let array = byteArrayFrom(swappedInt)
    return typeFromByteArray(array, Float.self)
}

func swapDoubleBytes(input: Int64) -> Double {
    let swappedInt = swapInt64Bytes(input)
    let array = byteArrayFrom(swappedInt)
    return typeFromByteArray(array, Double.self)
}

func swapInt16Bytes(input: Int16) -> Int16 {
    #if os(Linux)
    return Int16(htons(__uint16_t(input)))
    #else
    let byteArray = byteArrayFrom(input)
    return typeFromByteArray(byteArray.reverse(), Int16.self)
    #endif
}

func swapInt32Bytes(input: Int32) -> Int32 {
    #if os(Linux)
    return Int32(htonl(__uint32_t(input)))
    #else
    let byteArray = byteArrayFrom(input)
    return typeFromByteArray(byteArray.reverse(), Int32.self)
    #endif
}

func swapInt64Bytes(input: Int64) -> Int64 {
    let byteArray = byteArrayFrom(input)
    return typeFromByteArray(byteArray.reverse(), Int64.self)
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

func byteArrayForPointer(start: UnsafeMutablePointer<Int8>, length: Int) -> [UInt8] {
    let bytePointer = UnsafeMutablePointer<UInt8>(start)
    return Array(UnsafeBufferPointer(start: bytePointer, count: length))
}
