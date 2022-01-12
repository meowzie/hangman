# frozen_string_literal: true

# Creates a new game
class Game
  def initialize
    @word = Word.new
  end

  def play
    word = @word.choose
    answer = Answer.new(word)
    blanks = answer.show
    puts word
    puts blanks
    puts answer.update(gets.chomp)
  end

  # Creates words using the dictionary
  class Word
    attr_accessor :chosen

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

  # Contains functionality to display the blanks/answer and to allow the player to make guesses
  class Answer
    attr_accessor :blanks

    def initialize(answer)
      @answer = answer.downcase
      @length = answer.length
    end

    def show
      @blanks = ''.rjust(@length, '_')
    end

    def update(guess)
      return puts 'Invalid input. Please input one letter' unless guess.length == 1

      guess.downcase!
      corrects = @answer.each_char.with_index.map { |letter, index| index if letter == guess }
      corrects.compact!

      corrects.each { |index| @blanks[index] = guess }
      @blanks
    end
  end
end

Game.new.play
