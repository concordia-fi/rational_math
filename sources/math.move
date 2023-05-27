module rationalmath::decimal {

  const ERR_DIV_BY_ZERO: u64 = 22001;
  const ERR_OUT_OF_RANGE: u64 = 22002;
  const ERR_DIFFERENT_SCALE: u64 = 22003;

  struct Decimal has drop, copy, store {
    value: u256,
    scale: u8
  }

  //----------------------------------------------------------
  //                        Scales
  //----------------------------------------------------------
  const UNIFIED_SCALE: u8 = 9;

  //----------------------------------------------------------
  //                      Utilities
  //----------------------------------------------------------

  public fun new(v: u256, s: u8): Decimal {
    Decimal {
      value: v,
      scale: s,
    }
  }

  public fun val(d: &Decimal): u256 {
    d.value
  }
  
  public fun scale(d: &Decimal): u8 {
    d.scale
  }

  public fun decimal_scale_to_num(d: &Decimal): u256 {
    pow_u256(10u256, (d.scale as u256))
  }

  public fun adjust_scale(d: &mut Decimal, new_scale: u8) {
    assert!(new_scale > 0, ERR_OUT_OF_RANGE);
    if (d.scale == new_scale) {
     return
    };
    if (d.scale > new_scale) {
      let e: u8 = d.scale - new_scale;
      d.value = d.value /  pow_u256(10u256, (e as u256));
      d.scale = new_scale;
    }
    else {
      let e: u8 = new_scale - d.scale;
      d.value = d.value * pow_u256(10u256, (e as u256));
      d.scale = new_scale;
    }
  }

  //----------------------------------------------------------
  //                     Arithmetic
  //----------------------------------------------------------

  //adds two decimals of the same scale, aborts if overflow
  public fun add(d1: Decimal, d2: Decimal): Decimal {
    assert!(d1.scale == d2.scale, ERR_DIFFERENT_SCALE);
    Decimal {
      value: d1.value + d2.value,
      scale: d1.scale,
    }
  }

  //subs two decimals of the same scale, returns none if underflow
  public fun sub(larger: Decimal, smaller: Decimal): Decimal {
    assert!(larger.scale == smaller.scale, ERR_DIFFERENT_SCALE);
    Decimal {
      value: larger.value - smaller.value,
      scale: larger.scale,
    }
  }

  //multiplies two decimals, can handle different scales, can overflow
  public fun mul(d1: Decimal, d2: Decimal): Decimal {
    let denom = decimal_scale_to_num(&d2);
    Decimal {
      value: ((d1.value * d2.value) + (denom - 1)) / denom,
      scale: d1.scale,
    }
  }

  //divides two decimals with floor div, can handle different scales
  public fun div_floor(d1: Decimal, d2: Decimal): Decimal {
    assert!(d2.value != 0, ERR_DIV_BY_ZERO);
    
    if (d1.value == 0) {
      return Decimal {
        value: 0,
        scale: d1.scale
      }
    };

    Decimal {
      value: (d1.value * decimal_scale_to_num(&d2)) / d2.value,
      scale: d1.scale
    }
  }

  //divides two decimals with ceiling div
  public fun div_ceiling(d1: Decimal, d2: Decimal): Decimal {
    assert!(d2.value != 0, ERR_DIV_BY_ZERO);
    
    if (d1.value == 0) {
      return Decimal {
        value: 0,
        scale: d1.scale
      }
    };

    Decimal {
      value: ((d1.value * decimal_scale_to_num(&d2)) + (d2.value - 1)) / d2.value,
      scale: d1.scale
    }
  }

  //----------------------------------------------------------
  //                     Comparisons
  //----------------------------------------------------------
  public fun lt(d1: Decimal, d2: Decimal): bool {
    assert!(d1.scale == d2.scale, ERR_DIFFERENT_SCALE);
    return d1.value < d2.value
  }

  public fun gt(d1: Decimal, d2: Decimal): bool {
    assert!(d1.scale == d2.scale, ERR_DIFFERENT_SCALE);
    return d1.value > d2.value
  }

  public fun lte(d1: Decimal, d2: Decimal): bool {
    assert!(d1.scale == d2.scale, ERR_DIFFERENT_SCALE);
    return d1.value <= d2.value
  }

  public fun gte(d1: Decimal, d2: Decimal): bool {
    assert!(d1.scale == d2.scale, ERR_DIFFERENT_SCALE);
    return d1.value >= d2.value
  }

  public fun eq(d1: Decimal, d2: Decimal): bool {
    assert!(d1.scale == d2.scale, ERR_DIFFERENT_SCALE);
    return d1.value == d2.value
  }

  //---------------------------------------------------------- 
  //                       Internal
  //----------------------------------------------------------

  fun min_u256(first: u256, second: u256): u256 {
    if (first < second) {
      return first
    } else {
      return second
    }
  }

  fun max_u256(first: u256, second: u256): u256 {
    if (first > second) {
      return first
    } else {
      return second
    }
  }

  fun max_u8(first: u8, second: u8): u8 {
    if (first > second) {
      return first
    } else {
      return second
    }
  }

  fun pow_u256(n: u256, e:u256): u256 {
    if (e == 0) {
        1
    } else {
        let p = 1;
        while (e > 1) {
            if (e % 2 == 1) {
                p = p * n;
            };
            e = e / 2;
            n = n * n;
        };
        p * n
    }
  }
}

#[test_only]
module rationalmath::test_decimal {
use rationalmath::decimal as dec;
const UNIFIED_SCALE: u8 = 9;
const MAX_U256: u256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

  #[test(account = @rationalmath)]
  public entry fun test_new_raw() {
    let five = dec::new(5, UNIFIED_SCALE);
    assert!(dec::val(&five) == 5 && dec::scale(&five) == UNIFIED_SCALE, 0)
  }

  #[test(account = @rationalmath)]
  public entry fun test_decimal_scale_to_num() {
    let dec = dec::new(1800, 6);
    assert!(dec::decimal_scale_to_num(&dec) == 1000000,0)
  }

  #[test(account = @rationalmath)]
  public entry fun test_scaling() {
    let dec = dec::new(1200, 6);
    dec::adjust_scale(&mut dec, 7);
    assert!(dec::val(&dec) == 12000 && dec::scale(&dec) == 7, 0);
    dec::adjust_scale(&mut dec, 5);
    assert!(dec::val(&dec) == 120 && dec::scale(&dec) == 5, 0);
    dec::adjust_scale(&mut dec, 5);
    assert!(dec::val(&dec) == 120 && dec::scale(&dec) == 5, 0);
  }

  #[test(account = @rationalmath)]
  public entry fun test_add() {
    let dec1 = dec::new(1500, 6);
    let dec2 = dec::new(1500, 6);
    let result = dec::add(dec1, dec2);
    assert!(dec::val(&result) == 3000 && dec::scale(&result) == 6, 0);
  }

  #[test(account = @rationalmath)]
  #[expected_failure]
  public entry fun test_add_aborts_on_overflow() {
    let dec3 = dec::new(MAX_U256, 6);
    let dec4 = dec::new(1, 6);
    dec::add(dec3, dec4);
  }

  #[test(account = @rationalmath)]
  public entry fun test_sub() {
    let dec1 = dec::new(1300, 6);
    let dec2 = dec::new(300, 6);
    let result = dec::sub(dec1, dec2);
    assert!(dec::val(&result) == 1000 && dec::scale(&result) == 6, 0);
  }

  #[test(account = @rationalmath)]
  #[expected_failure]
  public entry fun test_sub_aborts_on_underflow() {
    let dec1 = dec::new(10, 6);
    let dec2 = dec::new(11, 6);
    dec::sub(dec1, dec2);
  }

  #[test(account = @rationalmath)]
  public entry fun test_mul() {
    let dec1 = dec::new(3000, 6);
    let dec2 = dec::new(9000, 3);
    let result = dec::mul(dec1, dec2);
    assert!(dec::val(&result) == 27000 && dec::scale(&result) == 6, 0);
    let dec3 = dec::new(3000, 3);
    let dec4 = dec::new(9000, 6);
    let result2 = dec::mul(dec3, dec4);
    assert!(dec::val(&result2) == 27 && dec::scale(&result2) == 3, 0);
    let dec5 = dec::new(72000000000, 8);
    let dec6 = dec::new(700000000, 8);
    let result = dec::mul(dec5, dec6);
    assert!(dec::val(&result) == 504000000000 && dec::scale(&result) == 8, 0);
  }

  #[test(account = @rationalmath)]
  #[expected_failure]
  public entry fun test_mul_aborts_on_overflow() {
    let dec1 = dec::new(MAX_U256, 6);
    let dec2 = dec::new(200, 6);
    dec::mul(dec1, dec2);
  }

  #[test(account = @rationalmath)]
  public entry fun test_div_floor() {
    let dec1 = dec::new(5000, 3);
    let dec2 = dec::new(5000, 3);
    let result = dec::div_floor(dec1, dec2);
    assert!(dec::val(&result) == 1000 && dec::scale(&result) == 3, 0);

    let dec1 = dec::new(3000, 6);
    let dec2 = dec::new(9000, 3);
    let result = dec::div_floor(dec1, dec2);
    assert!(dec::val(&result) == 333 && dec::scale(&result) == 6, 0);
    
    let dec1 = dec::new(3000, 3);
    let dec2 = dec::new(9000, 6);
    let result2 = dec::div_floor(dec1, dec2);
    assert!(dec::val(&result2) == 333333 && dec::scale(&result2) == 3, 0);
    
    let dec9 = dec::new(720000000000, 8);
    let dec10 = dec::new(720000000, 8);
    let result = dec::div_floor(dec9, dec10);
    assert!(dec::val(&result) == 100000000000 && dec::scale(&result) == 8, 0);
  }
  
  #[test(account = @rationalmath)]
  public entry fun test_div_ceiling() {
    let dec1 = dec::new(3000, 6);
    let dec2 = dec::new(9000, 3);
    let result = dec::div_ceiling(dec1, dec2);
    assert!(dec::val(&result) == 334 && dec::scale(&result) == 6, 0);
    let dec3 = dec::new(3000, 3);
    let dec4 = dec::new(9000, 6);
    let result2 = dec::div_ceiling(dec3, dec4);
    assert!(dec::val(&result2) == 333334 && dec::scale(&result2) == 3, 0);
  }

  #[test(account = @rationalmath)]
  public entry fun test_zero_scale_division() {
    let dec1 = dec::new(48000000000000, 12);
    let dec2 = dec::new(48, 0);

    let result = dec::div_floor(dec1, dec2);
    assert!(dec::val(&result) == 1000000000000 && dec::scale(&result) == 12, 0); // 1E12
    let result = dec::div_ceiling(dec1, dec2);
    assert!(dec::val(&result) == 1000000000000 && dec::scale(&result) == 12, 0); // 1E12
  }

  #[test(account = @rationalmath)]
  public entry fun explicit_sanity_test_for_difference_between_floor_and_ceiling_div() {
    let dec1 = dec::new(3000, 3);
    let dec2 = dec::new(9000, 3);
    let result = dec::div_floor(dec1, dec2);
    assert!(dec::val(&result) == 333 && dec::scale(&result) == 3, 0);
    let result = dec::div_ceiling(dec1, dec2);
    assert!(dec::val(&result) == 334 && dec::scale(&result) == 3, 0);

    let dec3 = dec::new(720000000000, 8);
    let dec4 = dec::new(720000000, 8);
    let result = dec::div_ceiling(dec3, dec4);
    assert!(dec::val(&result) == 100000000000 && dec::scale(&result) == 8, 0);
    let result = dec::div_floor(dec3, dec4);
    assert!(dec::val(&result) == 100000000000 && dec::scale(&result) == 8, 0);

    let dec5 = dec::new(1000000000, 8);
    let dec6 = dec::new(100000000, 8);
    let result = dec::div_ceiling(dec5, dec6);
    assert!(dec::val(&result) == 1000000000 && dec::scale(&result) == 8, 0);
    let result = dec::div_floor(dec5, dec6);
    assert!(dec::val(&result) == 1000000000 && dec::scale(&result) == 8, 0);
  }

#[test(account = @rationalmath)]
  public entry fun test_div_fractional() {
    let dec1 = dec::new(1000, 1);
    let dec2 = dec::new(10, 3);

    // 100.0 / .01 == 10000
    let result = dec::div_ceiling(dec1, dec2);
    assert!(dec::val(&result) == 100000 && dec::scale(&result) == 1, 1);
    let result = dec::div_floor(dec1, dec2);
    assert!(dec::val(&result) == 100000 && dec::scale(&result) == 1, 2);

    let dec1 = dec::new(1000, 2);

    let dec2 = dec::new(10, 3);

    // 10.00 / .01 == 1000
    let result = dec::div_ceiling(dec1, dec2);
    assert!(dec::val(&result) == 100000 && dec::scale(&result) == 2, 1);
    let result = dec::div_floor(dec1, dec2);
    assert!(dec::val(&result) == 100000 && dec::scale(&result) == 2, 2);
  }


  #[test(account = @rationalmath)]
  public entry fun test_lt() {
    let dec1 = dec::new(3000, 3);
    let dec2 = dec::new(3000, 3);
    let dec3 = dec::new(4000, 3);
    assert!(dec::lt(dec2, dec3), 0);
    assert!(!dec::lt(dec1, dec2), 0);
  }

  #[test(account = @rationalmath)]
  public entry fun test_gt() {
    let dec1 = dec::new(3000, 3);
    let dec2 = dec::new(3000, 3);
    let dec3 = dec::new(4000, 3);
    assert!(dec::gt(dec3, dec2), 0);
    assert!(!dec::gt(dec1, dec2), 0);
  }

  #[test(account = @rationalmath)]
  public entry fun test_lte() {
    let dec1 = dec::new(3000, 3);
    let dec2 = dec::new(3000, 3);
    let dec3 = dec::new(4000, 3);
    assert!(dec::lte(dec2, dec3), 0);
    assert!(dec::lte(dec2, dec1), 0);
  }

  #[test(account = @rationalmath)]
  public entry fun test_gte() {
    let dec1 = dec::new(3000, 3);
    let dec2 = dec::new(3000, 3);
    let dec3 = dec::new(4000, 3);
    assert!(dec::gte(dec3, dec2), 0);
    assert!(dec::gte(dec2, dec1), 0);
  }

  #[test(account = @rationalmath)]
  public entry fun test_eq() {
    let dec1 = dec::new(3000, 3);
    let dec2 = dec::new(3000, 3);
    let dec3 = dec::new(4000, 3);
    assert!(!dec::eq(dec3, dec2), 0);
    assert!(dec::eq(dec2, dec1), 0);
  }
}
