# encoding: utf-8

require 'rspec'
require 'numscaler'

describe NumScaler do
  it 'should have a VERSION constant' do
    NumScaler::VERSION.should_not be_empty
  end

  it 'should have an EPSILON constant' do
    NumScaler::EPSILON.should > 0
  end

  it 'should define clamping MODES' do
    NumScaler::MODES.should_not be_empty
  end

  it 'should check arguments' do
    lambda {
      NumScaler.new(1..8, 16..32, :nonext)
    }.should raise_error(ArgumentError)
  end

  context 'should work with Integer <=> Integer ranges and' do
    it 'should convert from' do
      scaler = NumScaler.new(1..8, 16..32)

      scaler.from(1).should eq 16
      scaler.from(4).should eq 23
      scaler.from(8).should eq 32
    end

    it 'should convert to' do
      scaler = NumScaler.new(1..8, -32..32)

      scaler.to(-32).should eq 1
      scaler.to(  0).should eq 5
      scaler.to( 32).should eq 8
    end
  end

  context 'should work with Integer <=> Float ranges and' do
    before(:all) do
      @prec = NumScaler::EPSILON
    end

    it 'should convert from' do
      scaler = NumScaler.new(0..15, 0.0..Math::PI)
      scaler.from( 0  ).should eq 0.0
      scaler.from( 7.5).should eq (Math::PI/2.0).round(@prec)
      scaler.from(15  ).should eq Math::PI.round(@prec)

      scaler = NumScaler.new(-15..15, 0.0..Math::PI)
      scaler.from(-15).should eq 0.0
      scaler.from(  0).should eq (Math::PI/2.0).round(@prec)
      scaler.from( 15).should eq Math::PI.round(@prec)
    end

    it 'should convert to' do
      scaler = NumScaler.new(0..15, 0.0..Math::PI)
      scaler.to(0.0).should          eq  0
      scaler.to(Math::PI/2.0).should eq  7
      scaler.to(Math::PI).should     eq 15

      scaler = NumScaler.new(-15..15, 0.0..Math::PI)
      scaler.to(0.0).should          eq -15
      scaler.to(Math::PI/2.0).should eq   0
      scaler.to(Math::PI).should     eq  15
    end
  end

  context 'should work with Float <=> Float ranges and' do
    before(:all) do
      @prec = NumScaler::EPSILON
    end

    it 'should convert from' do
      scaler = NumScaler.new(0.0..256.0, 0.0..Math::PI)
      scaler.from(  0.0).should eq 0.0
      scaler.from( 32.0).should eq (Math::PI/8.0).round(@prec)
      scaler.from( 64.0).should eq (Math::PI/4.0).round(@prec)
      scaler.from(128.0).should eq (Math::PI/2.0).round(@prec)
      scaler.from(256.0).should eq Math::PI.round(@prec)

      scaler = NumScaler.new(0.0..256.0, -Math::PI..Math::PI)
      scaler.from(  0.0).should eq -Math::PI.round(@prec)
      scaler.from( 64.0).should eq (-Math::PI/2.0).round(@prec)
      scaler.from(128.0).should eq 0.0
      scaler.from(192.0).should eq (Math::PI/2.0).round(@prec)
      scaler.from(256.0).should eq Math::PI.round(@prec)
    end

    it 'should convert to' do
      scaler = NumScaler.new(0.0..256.0, 0.0..Math::PI)
      scaler.to(0.0).should          eq   0.0
      scaler.to(Math::PI/8.0).should eq  32.0
      scaler.to(Math::PI/4.0).should eq  64.0
      scaler.to(Math::PI/2.0).should eq 128.0
      scaler.to(Math::PI).should     eq 256.0

      scaler = NumScaler.new(0.0..256.0, -Math::PI..Math::PI)
      scaler.to(-Math::PI).should     eq   0.0
      scaler.to(-Math::PI/2.0).should eq  64.0
      scaler.to(0.0).should           eq 128.0
      scaler.to(Math::PI/2.0).should  eq 192.0
      scaler.to(Math::PI).should      eq 256.0
    end
  end

  context 'should :strict clamp properly' do
    it 'with Integer ranges' do
      scaler = NumScaler.new(1..8, -5..5)
      lambda { scaler.from(-1) }.should raise_error ArgumentError
      lambda { scaler.from( 0) }.should raise_error ArgumentError
      lambda { scaler.from( 9) }.should raise_error ArgumentError
      lambda { scaler.to(-6) }.should raise_error ArgumentError
      lambda { scaler.to( 6) }.should raise_error ArgumentError
    end

    it 'with Float ranges' do
      scaler = NumScaler.new(0.5..1.25, -5.0..5.0)
      lambda { scaler.from(0.42 ) }.should raise_error ArgumentError
      lambda { scaler.from(0.499) }.should raise_error ArgumentError
      lambda { scaler.from(1.26 ) }.should raise_error ArgumentError
      lambda { scaler.from(1.3  ) }.should raise_error ArgumentError
      lambda { scaler.to(-5.1) }.should raise_error ArgumentError
      lambda { scaler.to( 5.1) }.should raise_error ArgumentError
    end
  end

  context 'should :clamp clamp properly' do
    it 'with Integer ranges' do
      scaler = NumScaler.new(1..8, -32..32, :clamp)
      scaler.from(-1).should eq -32
      scaler.from( 0).should eq -32
      scaler.from( 9).should eq  32
      scaler.to(-33).should eq 1
      scaler.to(  0).should eq 5
      scaler.to( 33).should eq 8
    end

    it 'with Float ranges' do
      scaler = NumScaler.new(1.0..8.0, -32.0..32.0, :clamp)
      scaler.from(0.89).should eq -32.0
      scaler.from(8.01).should eq  32.0
      scaler.to(-32.1).should eq 1.0
      scaler.to( 32.1).should eq 8.0
    end
  end

  context 'should :cycle clamp properly' do
    it 'with Integer ranges' do
      scaler = NumScaler.new(1..8, -8..-1, :cycle)
      scaler.from(-2).should eq -4
      scaler.from( 0).should eq -2
      scaler.from( 2).should eq -7
      scaler.from( 9).should eq -7
      scaler.to(-9).should eq 7
      scaler.to( 0).should eq 2

      scaler = NumScaler.new(-5..5, 20..30, :cycle)
      scaler.from(-8).should eq 27
      scaler.from(-7).should eq 28
      scaler.from(-6).should eq 29
      scaler.from( 6).should eq 21
      scaler.from( 7).should eq 22
      scaler.to(18).should eq  3
      scaler.to(19).should eq  4
      scaler.to(31).should eq -4
      scaler.to(41).should eq -4
    end

    it 'with Float ranges' do
      scaler = NumScaler.new(-2.5..2.5, 20.0..30.0, :cycle)
      scaler.from(-6.0).should eq 23.0
      scaler.from(-2.0).should eq 21.0
      scaler.from( 0.0).should eq 25.0
      scaler.from( 3.0).should eq 21.0
      scaler.from( 6.0).should eq 27.0
    end
  end
end
