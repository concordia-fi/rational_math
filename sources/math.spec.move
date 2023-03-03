spec rationalmath::decimal {
    spec add {
        ensures result.scale == d1.scale;
        ensures result.scale == d2.scale;
        ensures result.value == d1.value + d2.value;
        aborts_if d1.scale != d2.scale with ERR_DIFFERENT_SCALE;
        aborts_if d1.value + d2.value > MAX_U256 with EXECUTION_FAILURE;
    }

    spec sub {
        ensures result.scale == larger.scale;
        ensures result.scale == smaller.scale;
        ensures result.value == larger.value - smaller.value;
        aborts_if larger.scale != smaller.scale with ERR_DIFFERENT_SCALE;
        aborts_if smaller.value > larger.value with EXECUTION_FAILURE;
    }

    spec mul {
        ensures result.scale == d1.scale;
        ensures result.value == d1.value * d2.value;
        aborts_if d1.value * d2.value > MAX_U256 with EXECUTION_FAILURE;
        aborts_if spec_denominator(d2) == 0 with EXECUTION_FAILURE;
    }

    spec div_floor {
        ensures result.scale == d1.scale;
        ensures result.value == (d1.value * spec_denominator(d2)) / d2.value;

        aborts_if d2.value == 0 with ERR_DIV_BY_ZERO;
    }

    spec div_ceiling {
        ensures result.scale == d1.scale;
        ensures result.value == ((d1.value * spec_denominator(d2)) + (d2.value - 1)) / d2.value;

        aborts_if d2.value == 0 with ERR_DIV_BY_ZERO;
    }

    spec denominator {
        pragma opaque;
        aborts_if [abstract] spec_pow_u256(10, d.scale) > MAX_U256;
        ensures [abstract] result == spec_denominator(d);
    }

    spec fun spec_denominator(d: Decimal): u256 {
        spec_pow_u256(10, d.scale)
    }

    spec pow_u256(n: u256, e: u256): u256 {
        pragma opaque;
        aborts_if [abstract] spec_pow_u256(n, e) > MAX_U256;
        ensures [abstract] result == spec_pow_u256(n, e);
    }

    spec fun spec_pow_u256(e: u256, n: u256): u256 {
        if (e == 0) {
            1
        }
        else {
            n * spec_pow_u256(n, e-1)
        }
    }

}
