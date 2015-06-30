#!/usr/bin/env ruby

# Credit: Matthew (http://rubyquiz.com/quiz24.html)

FACES = "AKQJT98765432"
SUITS = "cdhs"

srand

# build a deck
deck = []
FACES.each_byte do |f|
  SUITS.each_byte do |s|
    deck.push(f.chr + s.chr)
  end
end

# shuffle deck
3.times do
  shuf = []
  deck.each do |c|
    loc = rand(shuf.size + 1)
    shuf.insert(loc, c)
  end
  deck = shuf.reverse
end

# deal common cards
common = Array.new(5) { deck.pop }

# deal player's hole cards
hole = Array.new(8) { Array.new(2) { deck.pop } }

# output hands
hands = []
all_fold = true
while all_fold do
  hands = []
  hole.each do |h|
    num_common = [0, 3, 4, 5][rand(4)]
    if num_common == 5
      all_fold = false
    end
    if num_common > 0
      hand = h + common[0 ... num_common]
    else
      hand = h
    end
    hands.push(hand.join(' '))
  end
end

hands.each { |h| puts h }