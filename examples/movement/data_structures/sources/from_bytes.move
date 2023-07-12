// Copyright (c) Movement Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module ds_std::from_bytes {
    use std::vector;

    /// Errors
    const EIndexOutOfBound: u64 = 0;
    const EInvalidVariable: u64 = 1;

    /// Read a `bool` value from bcs-serialized bytes.
    public fun read_bool(bytes: &vector<u8>): bool {
        let value = read_u8(bytes);
        if (value == 0) {
            false
        } else if (value == 1) {
            true
        } else {
            abort EInvalidVariable
        }
    }

    /// Read `u8` value from bcs-serialized bytes.
    public fun read_u8(bytes: &vector<u8>): u8 {
        let len = vector::length(bytes);
        assert!(len >= 1, EIndexOutOfBound);
        *vector::borrow(bytes, len - 1)
    }

    /// Read `u64` value from bcs-serialized bytes.
    public fun read_u64(bytes: &vector<u8>): u64 {
        let len = vector::length(bytes);
        assert!(len >= 8, EIndexOutOfBound);

        let (value, i, j) = (0u64, 0u8, 1u64);
        while (i < 64) {
            let byte = (*vector::borrow(bytes, len - j) as u64);
            value = value + (byte << i);
            i = i + 8;
            j = j + 1;
        };

        value
    }

    /// Read `u128` value from bcs-serialized bytes.
    public fun read_u128(bytes: &vector<u8>): u128 {
        let len = vector::length(bytes);
        assert!(len >= 16, EIndexOutOfBound);

        let (value, i, j) = (0u128, 0u8, 1u64);
        while (i < 128) {
            let byte = (*vector::borrow(bytes, len - j) as u128);
            value = value + (byte << i);
            i = i + 8;
            j = j + 1;
        };

        value
    }
}