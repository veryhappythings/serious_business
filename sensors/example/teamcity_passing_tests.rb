#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
require 'mechanize'
require 'yaml'

DIR = File.dirname(File.expand_path(__FILE__))
config = YAML::load_file("#{DIR}/teamcity.yaml")

agent = Mechanize.new
#agent.log = Logger.new(STDOUT)
page = agent.get("#{config['url']}/login.html")
page = page.link_with(:text => 'Login as a Guest').click

tests = {}
page.search('//td[@class="projectName"]/a').each do |project|
  link = Mechanize::Page::Link.new(project, agent, page)
  project_page = link.click

  project_page.search('//a//span').each do |span|
    if span.text =~ /^Tests/
      tests[link.text] ||= []
      tests[link.text] << span.text
    end
  end
end

total_passed = 0
total_failed = 0
tests.each_pair do |proj, results|
  results.each do |res|
    matchdata = /^Tests (passed|failed): (\d+)(?:(?: \(\d+ new\))?, passed: (\d+))?/.match(res)
    if matchdata
      if matchdata[1] == 'passed'
        total_passed += matchdata[2].to_i
      else
        total_passed += matchdata[3].to_i
        total_failed += matchdata[2].to_i
      end
    end
  end
end

puts total_passed
