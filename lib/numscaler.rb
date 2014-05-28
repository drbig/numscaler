# encoding: utf-8

# See {file:README.md} for practical examples.
class NumScaler
  # NumScaler version string
  VERSION = '0.0.5'
  # Epsilon defines rounding precision
  EPSILON = 14
  # Available clamping modes
  MODES = [:strict, :cycle, :clamp]

  # Additional `options`:
  #
  #   * `:mode` - specify clamping mode (*default: `:strict`*)
  #   * `:precision` - specify Float rounding (*default: `EPSILON`*)
  #
  # Precision defines number of significant decimal digits for rounding.
  #
  # Current clamping modes:
  #
  #   * `:strict` - raise ArgumentError for out-of-range number (*default*)
  #   * `:clamp`  - clamp number to source range
  #   * `:cycle`  - treat range as a circle of values
  #
  # @param from [Range] source range
  # @param to [Range] target range
  # @param options [Hash] additional options
  def initialize(from, to, options = {})
    @mode = options[:mode] || MODES.first
    @prec = options[:precision] || EPSILON

    raise ArgumentError, 'Unknown mode' unless MODES.member? @mode
    raise ArgumentError, 'Precision out of range' unless @prec > 0

    @src = { :orig  => from.min,
             :range => from.max.to_f - from.min.to_f,
             :max   => from.max.to_f,
             :min   => from.min.to_f }
    @tgt = { :orig  => to.min,
             :range => to.max.to_f - to.min.to_f,
             :max   => to.max.to_f,
             :min   => to.min.to_f }
  end

  # Convert number from source to target
  #
  # @param num [Numeric]
  # @return [Numeric]
  def from(num); calc(num, @src, @tgt); end

  # Convert number from target to source
  #
  # @param num [Numeric]
  # @return [Numeric]
  def to(num);   calc(num, @tgt, @src); end

  private
  # Perform actual calculation:
  #
  #   1. First check and if necessary apply clamping
  #   1. Then convert between ranges
  #   1. Lastly check how to exactly return the result and do so
  #
  # @param num [Numeric] number to convert
  # @param a [Hash] source range data
  # @param b [Hash] target range data
  # @return [Numeric]
  def calc(num, a, b)
    num = num.to_f

    unless num.between?(a[:min], a[:max])
      num = case @mode
            when :cycle
              ((num - a[:min]) % (a[:range])) + a[:min]
            when :clamp
              num > a[:max] ? a[:max] : a[:min]
            when :strict
              raise ArgumentError, 'Number out of range'
            end
    end

    res = (((num - a[:min]) * b[:range]) / a[:range]) + b[:min]

    case b[:orig]
    when Integer
      res.round
    else
      res.round(@prec)
    end
  end
end
