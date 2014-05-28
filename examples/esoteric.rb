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
