# encoding: utf-8

require 'rspec'
require 'numscaler'

RSpec.configure do |c|
  c.expect_with :rspec do |cc|
    cc.syntax = :expect
  end
end

describe NumScaler do
  it 'should have a VERSION constant' do
    expect(NumScaler::VERSION).to_not be_empty
  end

  it 'should have an EPSILON constant' do
    expect(NumScaler::EPSILON).to be > 0
  end

  it 'should define clamping MODES' do
    expect(NumScaler::MODES).to_not be_empty
  end

  it 'should check arguments' do
    expect {
      NumScaler.new(1..8, 16..32, :mode => :nonext)
    }.to raise_error(ArgumentError)
    expect {
      NumScaler.new(1..8, 16..32, :precision => 0)
    }.to raise_error(ArgumentError)
  end

  context 'should work with Integer <=> Integer ranges and' do
    it 'should convert from' do
      s = NumScaler.new(1..8, 16..32)

      expect(s.from(1)).to eql 16
      expect(s.from(4)).to eql 23
      expect(s.from(8)).to eql 32
    end

    it 'should convert to' do
      s = NumScaler.new(1..8, -32..32)

      expect(s.to(-32)).to eql 1
      expect(s.to(  0)).to eql 5
      expect(s.to( 32)).to eql 8
    end
  end

  context 'should work with Integer <=> Float ranges and' do
    before(:all) do
      @prec = NumScaler::EPSILON
    end

    it 'should convert from' do
      s = NumScaler.new(0..15, 0.0..Math::PI)
      expect(s.from( 0  )).to eql 0.0
      expect(s.from( 7.5)).to eql (Math::PI/2.0).round(@prec)
      expect(s.from(15  )).to eql Math::PI.round(@prec)

      s = NumScaler.new(-15..15, 0.0..Math::PI)
      expect(s.from(-15)).to eql 0.0
      expect(s.from(  0)).to eql (Math::PI/2.0).round(@prec)
      expect(s.from( 15)).to eql Math::PI.round(@prec)
    end

    it 'should convert to' do
      s = NumScaler.new(0..15, 0.0..Math::PI)
      expect(s.to(0.0)).to          eql  0
      expect(s.to(Math::PI/2.0)).to eql  7
      expect(s.to(Math::PI)).to     eql 15

      s = NumScaler.new(-15..15, 0.0..Math::PI)
      expect(s.to(0.0)).to          eql -15
      expect(s.to(Math::PI/2.0)).to eql   0
      expect(s.to(Math::PI)).to     eql  15
    end
  end

  context 'should work with Float <=> Float ranges and' do
    before(:all) do
      @prec = NumScaler::EPSILON
    end

    it 'should convert from' do
      s = NumScaler.new(0.0..256.0, 0.0..Math::PI)
      expect(s.from(  0.0)).to eql 0.0
      expect(s.from( 32.0)).to eql (Math::PI/8.0).round(@prec)
      expect(s.from( 64.0)).to eql (Math::PI/4.0).round(@prec)
      expect(s.from(128.0)).to eql (Math::PI/2.0).round(@prec)
      expect(s.from(256.0)).to eql Math::PI.round(@prec)

      s = NumScaler.new(0.0..256.0, -Math::PI..Math::PI)
      expect(s.from(  0.0)).to eql -Math::PI.round(@prec)
      expect(s.from( 64.0)).to eql (-Math::PI/2.0).round(@prec)
      expect(s.from(128.0)).to eql 0.0
      expect(s.from(192.0)).to eql (Math::PI/2.0).round(@prec)
      expect(s.from(256.0)).to eql Math::PI.round(@prec)
    end

    it 'should convert to' do
      s = NumScaler.new(0.0..256.0, 0.0..Math::PI)
      expect(s.to(0.0)).to          eql   0.0
      expect(s.to(Math::PI/8.0)).to eql  32.0
      expect(s.to(Math::PI/4.0)).to eql  64.0
      expect(s.to(Math::PI/2.0)).to eql 128.0
      expect(s.to(Math::PI)).to     eql 256.0

      s = NumScaler.new(0.0..256.0, -Math::PI..Math::PI)
      expect(s.to(-Math::PI)).to     eql   0.0
      expect(s.to(-Math::PI/2.0)).to eql  64.0
      expect(s.to(0.0)).to           eql 128.0
      expect(s.to(Math::PI/2.0)).to  eql 192.0
      expect(s.to(Math::PI)).to      eql 256.0
    end
  end

  context 'should :strict clamp properly' do
    it 'with Integer ranges' do
      s = NumScaler.new(1..8, -5..5)
      expect { s.from(-1) }.to raise_error ArgumentError
      expect { s.from( 0) }.to raise_error ArgumentError
      expect { s.from( 9) }.to raise_error ArgumentError
      expect { s.to(-6) }.to raise_error ArgumentError
      expect { s.to( 6) }.to raise_error ArgumentError
    end

    it 'with Float ranges' do
      s = NumScaler.new(0.5..1.25, -5.0..5.0)
      expect { s.from(0.42 ) }.to raise_error ArgumentError
      expect { s.from(0.499) }.to raise_error ArgumentError
      expect { s.from(1.26 ) }.to raise_error ArgumentError
      expect { s.from(1.3  ) }.to raise_error ArgumentError
      expect { s.to(-5.1) }.to raise_error ArgumentError
      expect { s.to( 5.1) }.to raise_error ArgumentError
    end
  end

  context 'should :clamp clamp properly' do
    it 'with Integer ranges' do
      s = NumScaler.new(1..8, -32..32, :mode => :clamp)
      expect(s.from(-1)).to eql -32
      expect(s.from( 0)).to eql -32
      expect(s.from( 9)).to eql  32
      expect(s.to(-33)).to eql 1
      expect(s.to(  0)).to eql 5
      expect(s.to( 33)).to eql 8
    end

    it 'with Float ranges' do
      s = NumScaler.new(1.0..8.0, -32.0..32.0, :mode => :clamp)
      expect(s.from(0.89)).to eql -32.0
      expect(s.from(8.01)).to eql  32.0
      expect(s.to(-32.1)).to eql 1.0
      expect(s.to( 32.1)).to eql 8.0
    end
  end

  context 'should :cycle clamp properly' do
    it 'with Integer ranges' do
      s = NumScaler.new(1..8, -8..-1, :mode => :cycle)
      expect(s.from(-2)).to eql -4
      expect(s.from( 0)).to eql -2
      expect(s.from( 2)).to eql -7
      expect(s.from( 9)).to eql -7
      expect(s.to(-9)).to eql 7
      expect(s.to( 0)).to eql 2

      s = NumScaler.new(-5..5, 20..30, :mode => :cycle)
      expect(s.from(-8)).to eql 27
      expect(s.from(-7)).to eql 28
      expect(s.from(-6)).to eql 29
      expect(s.from( 6)).to eql 21
      expect(s.from( 7)).to eql 22
      expect(s.to(18)).to eql  3
      expect(s.to(19)).to eql  4
      expect(s.to(31)).to eql -4
      expect(s.to(41)).to eql -4
    end

    it 'with Float ranges' do
      s = NumScaler.new(-2.5..2.5, 20.0..30.0, :mode => :cycle)
      expect(s.from(-6.0)).to eql 23.0
      expect(s.from(-2.0)).to eql 21.0
      expect(s.from( 0.0)).to eql 25.0
      expect(s.from( 3.0)).to eql 21.0
      expect(s.from( 6.0)).to eql 27.0
    end
  end
end
