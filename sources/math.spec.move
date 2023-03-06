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

}
