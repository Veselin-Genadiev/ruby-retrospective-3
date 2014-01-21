class Integer
  def prime?
    return false if self < 2
    2.upto(self - 1).all? { |number| self % number != 0 }
  end

  def prime_factors
    number = self
    2.upto(abs).each_with_object([]) do |divisor, prime_factors|
      while number % divisor == 0
        prime_factors << divisor
        number /= divisor
      end
    end
  end

  def harmonic
    harmonic_number = Rational(0, 1)
    1.upto(self).each { |number| harmonic_number += Rational(1, number) }
    harmonic_number
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    frequencies_collection = {}
    self.each{|x| frequencies_collection[x] ?
        frequencies_collection[x] += 1 : frequencies_collection[x] = 1}
    frequencies_collection
  end

  def average
    reduce(:+).to_f / length unless length.zero?
  end

  def drop_every(n)
    find_all.each_with_index { |element, index| index % n != n - 1 }
  end

  def combine_with(other)
    longer, shorter = self.length > other.length ? [self, other] : [other, self]

    combined = take(shorter.length).zip(other.take(shorter.length)).flatten(1)
    rest     = longer.drop(shorter.length)

    combined + rest
  end
end