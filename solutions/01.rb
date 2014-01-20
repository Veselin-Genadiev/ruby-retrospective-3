class Integer
  def prime?
    return false if self < 2
    2.upto(self - 1).all? { |number| self % number != 0 }
  end

  def prime_factors
    list = []
    argument = self
    while argument.abs > 1
      list.push((2..argument).select{|x| (x.prime? && argument % x == 0)}.first)
      argument /= list.last
    end
    list
  end

  def harmonic
    harmonic_number = Rational(0, 1)
    counter = 1
    while counter <= self
      harmonic_number += Rational(1, counter)
      counter += 1
    end
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