# NumScaler

* [Homepage](https://github.com/drbig/numscaler)
* [Documentation](http://rubydoc.info/gems/numscaler/frames)

## Description

NumScaler will convert for you numbers between ranges using simple linear 
interpolation. In other words it will scale a number form its source range to a 
corresponding number within the target range. And vice-versa.

It has three clamping modes that are applied to the input number before 
conversion, and only if that number is outside its range:

  * `:strict` - will raise an exception (*default*)
  * `:clamp`  - will cut the number at the edges of the range (e.g. to min or 
max)
  * `:cycle`  - will treat the range as circular (think `number % range`)

It should work correctly for any combination of Integer and Float ranges (note 
that you can't mix numeric types within a single range, as it doesn't make much 
sense). It expects common-sense on your part, so trying to use it with empty 
ranges (e.g. `0..0`) is left as undefined (though it might work just as you 
expect, or not).

All calculations are done internally on `Float`s so there will be inevitable 
rounding errors. My tests show that the precision is within 14 decimal places, 
and therefore that is the default rounding.

There is a pretty brute-force test suite. Should work with any Ruby version.

## Examples

Install and run pry/irb:

    $ gem install numscaler
    $ pry

Simple Integer - Integer conversion:

    [1] pry(main)> require 'numscaler'
    [2] pry(main)> iti = NumScaler.new(0..15, 0..256)
    [3] pry(main)> iti.from(0)
    => 0
    [4] pry(main)> iti.from(7)
    => 119
    [5] pry(main)> iti.from(8)
    => 137
    [6] pry(main)> iti.to(128)
    => 8
    [7] pry(main)> iti.to(255)
    => 15
    [8] pry(main)> iti.from(-1)
    ArgumentError: Number out of range

Integer - Float conversion:

    [9] pry(main)> itf = NumScaler.new(0..7, 0.0..16.0)
    [10] pry(main)> itf.from(2)
    => 4.57142857142857
    [11] pry(main)> itf.from(7)
    => 16.0
    [12] pry(main)> itf.to(4)
    => 2
    [13] pry(main)> itf.to(4.234)
    => 2

Float - Float conversion:

    [14] pry(main)> ftf = NumScaler.new(-2.5..2.5, -5.0..5.0)
    [15] pry(main)> ftf.from(-2.0)
    => -4.0
    [16] pry(main)> ftf.to(-4.0)
    => -2.0
    [17] pry(main)> # deg - rad conversion
    [18] pry(main)> ftf = NumScaler.new(0.0..180.0, 0.0..Math::PI)
    [19] pry(main)> ftf.from(45.0)
    => 0.78539816339745
    [20] pry(main)> ftf.to(1.57079633)
    => 90.0000001836389

Clamping examples:

    [21] pry(main)> ftf = NumScaler.new(0.0..4.0, -2.5..2.5, :clamp)
    [22] pry(main)> ftf.from(-1.0)
    => -2.5
    [23] pry(main)> ftf.from(5.0)
    => 2.5
    [24] pry(main)> ftf.to(15.0)
    => 4.0
    
    [25] pry(main)> ftf = NumScaler.new(0.0..4.0, -2.5..2.5, :cycle)
    [26] pry(main)> ftf.from(-1.0)
    => 1.25
    [27] pry(main)> ftf.from(5.0)
    => -1.25
    [28] pry(main)> ftf.to(15.0)
    => 2.0

## Copyright

Copyright (c) 2014 Piotr S. Staszewski

Absolutely no warranty. See {file:LICENSE.txt} for details.
