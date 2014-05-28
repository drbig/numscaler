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
