#!/usr/bin/env ruby
require 'json'

if ARGV[0] == 'config'
  puts({
    'random' =>{
      'category' => 'example sensors',
      'alert' => {
        'min' => 4,
        'max' => 9
      }
    }
  }.to_json)
  exit
end
puts({'random' => rand(10)}.to_json)
