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
    digits_list = []
    number_positive = self.abs
    while number_positive > 0
      digits_list.push(number_positive % 10)
      number_positive /= 10
    end
    digits_list.reverse
  end
end

class Array
  def frequencies
    frequencies_hash = {}
    self.each{|x| frequencies_hash[x] ?
        frequencies_hash[x] += 1 : frequencies_hash[x] = 1}
    frequencies_hash
  end

  def average
    sum = 0.0
    self.each{|x| sum += x}
    avg = sum / self.length
  end

  def drop_every(n)
    nth_dropped_list = []
    counter = 0
    while counter < self.length
      nth_dropped_list.push(self[counter]) unless (counter + 1) % n == 0
      counter += 1
    end
    nth_dropped_list
  end

  def combine_with(other)
    list = []
    bigger = [self, other].max{|x, y| x.length <=> y.length}
    (0..[self.length, other.length].min - 1).
        each{|i| list.push(self[i], other[i])}
    (list.length / 2..bigger.length - 1).each{|i| list.push(bigger[i])}
    list
  end
end

puts