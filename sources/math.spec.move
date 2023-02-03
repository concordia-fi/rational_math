spec rationalmath::decimal {
    spec fun spec_pow(base: u128, exp: u8): u256 {
        if (exp == 0) {
            1
        }
        else {
            base * spec_pow(base, exp - 1)
        }
    }

    spec pow {
        ensures result == spec_pow(base, exp);
    }

    spec add {
        ensures result.scale == d1.scale;
        ensures result.scale == d2.scale;
        ensures result.value == d1.value + d2.value;
        aborts_if d1.scale != d2.scale with ERR_DIFFERENT_SCALE;
        aborts_if d1.value + d2.value > MAX_U128 with EXECUTION_FAILURE;
    }
}
