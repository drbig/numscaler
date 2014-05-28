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
