#!/usr/bin/env ruby

require 'pry-byebug'
require 'benchmark'

LIST = ["Royal Flush", "Straight Flush", "Four of a Kind", "Full House", "Flush", "Straight", "Three of a Kind", "Two Pair", "Pair", "High Card"]
VALUES = "AKQJT98765432".chars
SUITS = "shdc".chars

class Texas
  def initialize(sets_of_cards)
    @sets_of_cards = sets_of_cards 
    @parsed_hands = []
    @sets_of_cards.collect do |cards|
      @parsed_hands << CardSet.new(cards)
    end
    mark_winner
  end

  def render
    @parsed_hands.each do |card_set|
      puts card_set.render
    end
  end

  private 

  def mark_winner
    # use the spaceship operator to compare between CardSets?
  end
end

class CardSet
  attr_accessor :cards

  def initialize(cards)
    @cards = cards.split(' ')
    find_hand
  end

  def render
    cards.join(' ')
  end

  private

  def find_hand
    return cards if cards.size < 7
    check_straight # @sorted, @straight calculated here
    if is_royal_flush
      cards << LIST[0]
    elsif is_straight_flush
      cards << LIST[1]
    elsif is_four_of_a_kind
      cards << LIST[2]
    elsif is_full_house # @threes calculated here
      cards << LIST[3] 
    elsif is_flush
      cards << LIST[4]
    elsif is_straight
      cards << LIST[5] 
    elsif is_three_of_a_kind
      cards << LIST[6] 
    elsif is_two_pair
      cards << LIST[7]
    elsif is_pair
      cards << LIST[8]
    else # is High Card
      self.cards = @sorted
      cards << LIST[9]
    end
    cards
  end

  def check_straight
    # binding.pry
    @sorted = sort(self.cards) # find the value - e.g. "Kc" returns 1, which is the position of K in VALUES array
    # sorted must be unique by value
    unique_by_val = @sorted.uniq { |e| e[0] }
    unique_by_val.each_cons(5) do |cons|
      if find_difference_between(cons).all? { |d| d == 1 }
        # move straight to the front of the order
        @straight = cons
        return self.cards = cons + (@sorted - cons)
      end
    end 
    false
  end

  def is_royal_flush
    @straight && flush?(@straight) && ace?(@straight.first)
  end

  def is_straight_flush
    @straight && flush?(@straight)
  end

  def is_four_of_a_kind
    @sorted.each_cons(4) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        return self.cards = cons + (@sorted - cons)
      end
    end
    false
  end

  def is_full_house
    # find threes
    # set the remainder in a variable, or return false
    # find pair
    rem = nil
    @sorted.each_cons(3) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @threes = cons
        rem = @sorted - @threes
        self.cards = @threes + (@sorted - @threes) 
        # in case there is no full house, this puts the cards in order for Three of a Kind
      end
    end
    return false unless @threes

    rem.each_cons(2) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @pair = cons
        return self.cards = @threes + @pair + (rem - @pair)
      end
    end
    false
  end

  def is_flush
    sorted_by_suit = cards.sort_by { |c| c[1] }
    sorted_by_suit.each_cons(5) do |cons|
      if find_difference_between_suit(cons).all? { |d| d == 0 }
        return self.cards = sort(cons) + sort(sorted_by_suit - cons) 
        # we sort the flush so that the highest card is first, and also the kickers
      end
    end
    false
  end

  def is_straight
    @straight
  end

  def is_three_of_a_kind
    @threes
  end

  def is_two_pair
    rem = nil
    @sorted.each_cons(2) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @pair = cons
        rem = @sorted - @pair
        self.cards = @pair + (@sorted - @pair)
        # in case there is no Two Pair, this puts the cards in order for Pair
      end
    end

    return false unless @pair

    rem.each_cons(2) do |cons|
      if find_difference_between(cons).all? { |d| d == 0 }
        @pair2 = cons
        # sort the Two Pair such that the higher pair is first in order
        sorted_pairs = [@pair, @pair2].sort_by { |arr| VALUES.index(arr.first[0]) }
        return self.cards = sorted_pairs.flatten + (rem - @pair2)
      end
    end    
    false
  end

  def is_pair
    @pair
  end

  def flush?(sequence)
    return false unless sequence.length == 5
    sequence.uniq { |e| e[1] }.length == 1
  end

  def ace?(card)
    card[0] == "A"
  end

  def find_difference_between(cons)
    diffs = []
    cons.each_cons(2) { |x, y| diffs << (VALUES.index(y[0]) - VALUES.index(x[0])) } 
    diffs
  end

  def find_difference_between_suit(cons)
    diffs = []
    cons.each_cons(2) { |x, y| diffs << (SUITS.index(y[1]) - SUITS.index(x[1])) } 
    diffs
  end

  def sort(card_set)
    card_set.sort_by { |c| VALUES.index(c[0]) }
  end
end



unless ARGV.length == 1 && test(?e, ARGV[0])
  puts "Usage: #{$PROGRAM_NAME} hand.txt"
  exit
end

puts Benchmark.measure {
  game = Texas.new(ARGF.readlines.map(&:chomp))
  game.render
}