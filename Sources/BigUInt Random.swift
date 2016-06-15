//
//  BigUInt Random.swift
//  BigInt
//
//  Created by Károly Lőrentey on 2016-01-04.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import Foundation

extension BigUInt {
    //MARK: Random Integers

    /// Create a big integer consisting of `width` uniformly distributed random bits.
    ///
    /// - Returns: A big integer less than `1 << width`.
    /// - Note: This function uses `arc4random_buf` to generate random bits.
    @warn_unused_result
    public static func randomInteger(withMaximumWidth width: Int) -> BigUInt {
        guard width > 0 else { return 0 }

        let byteCount = (width + 7) / 8
        assert(byteCount > 0)

        let buffer = UnsafeMutablePointer<UInt8>(allocatingCapacity: byteCount)
        arc4random_buf(buffer, byteCount)
        if width % 8 != 0 {
            buffer[0] &= UInt8(1 << (width % 8) - 1)
        }
        defer {
            buffer.deinitialize(count: byteCount)
            buffer.deallocateCapacity(byteCount)
        }
        return BigUInt(Data(bytesNoCopy: buffer, count: byteCount, deallocator: .none))
    }

    /// Create a big integer consisting of `width-1` uniformly distributed random bits followed by a one bit.
    ///
    /// - Returns: A random big integer whose width is `width`.
    /// - Note: This function uses `arc4random_buf` to generate random bits.
    @warn_unused_result
    public static func randomInteger(withExactWidth width: Int) -> BigUInt {
        guard width > 1 else { return BigUInt(width) }
        var result = randomInteger(withMaximumWidth: width - 1)
        result[(width - 1) / Digit.width] |= 1 << Digit((width - 1) % Digit.width)
        return result
    }

    /// Create a uniformly distributed random integer that's less than the specified limit.
    ///
    /// - Returns: A random big integer that is less than `limit`.
    /// - Note: This function uses `arc4random_buf` to generate random bits.
    @warn_unused_result
    public static func randomIntegerLessThan(_ limit: BigUInt) -> BigUInt {
        let width = limit.width
        var random = randomInteger(withMaximumWidth: width)
        while random >= limit {
            random = randomInteger(withMaximumWidth: width)
        }
        return random
    }
}
