# frozen_string_literal: true

# Creates words using the dictionary
class Word
  def initialize
    @dictionary = File.readlines('5desk.txt').map(&:chomp)
    @chosen = ''
  end

  def choose
    until @chosen.length >= 5 && @chosen.length <= 12
      index = rand(0..@dictionary.length - 1)
      @chosen = @dictionary[index]
    end
    @chosen
  end
end
