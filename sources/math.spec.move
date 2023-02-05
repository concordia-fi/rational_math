spec rationalmath::decimal {
    spec add {
        ensures result.scale == d1.scale;
        ensures result.scale == d2.scale;
        ensures result.value == d1.value + d2.value;
        aborts_if d1.scale != d2.scale with ERR_DIFFERENT_SCALE;
        aborts_if d1.value + d2.value > MAX_U128 with EXECUTION_FAILURE;
    }
}
