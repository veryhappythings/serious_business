#!/usr/bin/env ruby

require 'logger'
require 'mechanize'
require 'json'

# Login junk
agent = Mechanize.new
#agent.log = Logger.new(STDOUT)
agent.basic_auth('username', 'password')
page = agent.get('http://127.0.0.1/login')

# The meat
page = agent.get('http://127.0.0.1/roadmap')
config = {}
result = {}
page.search('//div[@class="milestone"]').each do |milestone|
  open_tickets = 0
  heading = milestone.search('.//h2/a/em')[0].text
  milestone.search('.//dl').each do |line|
    text = line.text.gsub(/\s\s+/, '')
    data = /Number of tickets:closed:(\d+)in testing:(\d+)in progress:(\d+)Total:(\d+)/.match text
    open_tickets = data[2].to_i + data[3].to_i
  end

  # You can adjust the name of the results here.
  # In this example we regex out the branch names that we include in our
  # trac milestone names.
  key = heading.gsub(/[\s*:.]/, '_')
  heading = heading.gsub(/\(Branch: .+\)/, '').gsub('*', '')

  config[key] = {'category' => 'Trac', 'name' => "Open tickets in #{heading}"}
  result[key] = open_tickets
end

if ARGV[0] == 'config'
  puts config.to_json
else
  puts result.to_json
end
