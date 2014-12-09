# NumScaler [![Gem](http://img.shields.io/gem/v/numscaler.svg)](https://rubygems.org/gems/numscaler) [![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/github/drbig/numscaler/master)

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

## Applications

  * Scaling when graphing
    ...from `0.0..1.0` to `0..(height-1)`
  * Bounded unit conversion
    ...from Celsius to Fahrenheit, Centimeters to Inches
  * Circular unit conversion
    ...from degrees to radians
  * Value to index mapping
    ...from `0.0..1.0` to 'very bad' - 'very good'

## Examples

Install:

    $ gem install numscaler

From the `examples/` directory, first some graphing:

    require 'numscaler'
    
    s1 = NumScaler.new(0..64, 0.0..Math::PI*2.0)
    s2 = NumScaler.new(-1.0..1.0, 0..9)
    
    graph = (0..64).to_a.collect do |e|
      i = s2.from(Math.sin(s1.from(e)))
      a = [' '] * 10
      a[i] = '#'
      a
    end
    
    puts graph.transpose.collect {|e| e.join }

Running it will produce a lovely:

                                                #########            
                                            ####         ####        
                                         ###                 ###     
                                       ##                       ##   
                                     ##                           ## 
    ###                           ###                               #
       ##                       ##                                   
         ###                 ###                                     
            ####         ####                                        
                #########                                            

You can also use it for unit conversion if you wish, like so:

    require 'numscaler'
    
    distance = NumScaler.new(0.0..100.0, 0.0..39.3701)
    temperature = NumScaler.new(-30.0..120.0, -22.0..248.0)
    angle = NumScaler.new(0.0..90.0, 0.0..Math::PI/2.0)
    
    puts 'Distance:'
    [
      ['9 mm ammo', 0.9],
      ['max pin distance in an europlug', 1.86],
      ['average baguette length', 65.0],
    ].each do |label, cm|
      print "#{label} (#{cm} cm) is ".rjust(50)
      puts distance.from(cm).to_s + ' inch'
    end
    
    puts "\nTemperature:"
    [
      ['siberian cold', -25.0],
      ['minimal workplace temp', 18.0],
      ['usually comfortable', 25.0],
      ['Polish summer', 35.0],
    ].each do |label, cent|
      print "#{label} (#{cent} Celsius) is ".rjust(50)
      puts temperature.from(cent).to_s + ' Fahrenheit'
    end
    
    puts "\nAngle:"
    [
      ['human FOV blind spot width', 5.5],
      ['decent slope', 23.0],
      ['in the corner', 90.0],
    ].each do |label, deg|
      print "#{label} (#{deg} degrees) is ".rjust(50)
      puts angle.from(deg).to_s + ' radians'
    end

Which will produce:

    Distance:
                                9 mm ammo (0.9 cm) is 0.3543309 inch
          max pin distance in a europlug (1.86 cm) is 0.73228386 inch
                 average baguette length (65.0 cm) is 25.590565 inch
    
    Temperature:
                     siberian cold (-25.0 Celsius) is -13.0 Fahrenheit
             minimal workplace temp (18.0 Celsius) is 64.4 Fahrenheit
                usually comfortable (25.0 Celsius) is 77.0 Fahrenheit
                      Polish summer (35.0 Celsius) is 95.0 Fahrenheit
    
    Angle:
          human FOV blind spot width (5.5 degrees) is 0.09599310885969 radians
                       decent slope (23.0 degrees) is 0.4014257279587 radians
                      in the corner (90.0 degrees) is 1.5707963267949 radians

You can also do some esoteric stuff, like:

    require 'numscaler'
    
    palette = ' ,-\'"\\O/"\'-. '.split('')
    s = NumScaler.new(-1.0..1.0, 0..(palette.length - 1), :mode => :cycle)
    c = NumScaler.new(1..32, 0.0..Math::PI*2.0, :mode => :cycle)
    
    1.upto(256) do |o|
      puts "\e[H\e[2J"
      1.upto(32) do |y|
        1.upto(64) do |x|
          print palette[s.from(
            Math.tan(c.from(o)) *\
            (Math.sin(c.from(x)) +\
            Math.cos(c.from(y)))
          )]
        end
        print "\n"
      end
      print "\n"
      sleep(0.5)
    end

For this you'd have to run it in a terminal (and it will probably not work
as intended on windows).

## Copyright

Copyright (c) 2014 Piotr S. Staszewski

Absolutely no warranty. See {file:LICENSE.txt} for details.
