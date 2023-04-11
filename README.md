# Rational Math

## Building and testing

Install the [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli) then:

```
aptos move compile --named-addresses rational_math=<address>
aptos move test --named-addresses rational_math=<address>
```

## Features

#### Structs
Decimal struct has a value and a scale. Scale is an exponent of 10.
```
struct Decimal {
    value: u128,
    scale: u8
  }
``` 
#### Utility Functions
##### new
 Returns a decimal with the given value and scale.
```move
public fun new(v: u128, s: u8): Decimal 
```
##### is_zero
Returns true if the decimal is zero.
```move
  public fun is_zero(d: &Decimal): bool 
```
##### adjust_scale
Adjusts the scale of the decimal to the given scale.
```move
  public fun adjust_scale(d: &mut Decimal, new_scale: u8)
```
- Cannot be used to set the scale to 0
##### denominator
Returns 10 ^ scale.
```move
  public fun denominator(d: &Decimal): u128
```
##### pow
Returns base ^ exponent.
```move
  public fun pow(base: u128, exponent: u8): u128
```

#### Arithmetic
##### add
Adds two decimals of the same scale.
```move
  public fun add(d1: Decimal, d2: Decimal): Decimal
```
- Panics on different scales
##### sub
Subtracts two decimals of the same scale.
  ```move
  public fun sub(larger: Decimal, smaller: Decimal): Decimal 
  ```
- Panics on different scales
##### mul
Multiples two decimals of same or different scales.
```move
public fun mul(d1: Decimal, d2: Decimal): Decimal
```
- Keeps the scale of the first decimal
##### div_floor
Divides two decimals of same or different scales with floor division.
```move
public fun div_floor(d1: Decimal, d2: Decimal): Decimal 
```
- Keeps the scale of the first decimal
- Panics if the second decimal is zero
##### div_ceiling
Divides two decimals of same or different scales with ceiling division.
```move
public fun div_ceiling(d1: Decimal, d2: Decimal): Decimal 
```
- Keeps the scale of the first decimal
- Panics if the second decimal is zero

#### Comparison

##### eq
Returns true if the two decimals are equal.
```move
public fun eq(d1: Decimal, d2: Decimal): bool 
```
##### lt
Returns true if the first decimal is less than the second.
```move
public fun lt(d1: Decimal, d2: Decimal): bool 
```
##### gt
Returns true if the first decimal is greater than the second.
```move
public fun gt(d1: Decimal, d2: Decimal): bool 
```
##### lte
Returns true if the first decimal is less than or equal to the second.
```move
public fun le(d1: Decimal, d2: Decimal): bool 
```
##### gte
Returns true if the first decimal is greater than or equal to the second.
```move
public fun ge(d1: Decimal, d2: Decimal): bool 
```