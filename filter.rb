#!/usr/bin/env ruby

# Our web servers are organised so that each site has it's own
# access log. The only lines that appear in 'access.log' itself
# are from people trying to access the web server without knowing
# any of the host names. Almost always bad guys
#
# This experimental tool removes lines that are not necessarily
# the result of hacking attempts (such as search engines and mapping
# projects). What is left is probably just a list of hackers. Maybe
#
# Always review the output before banning addresses. I only ban if
# they occur 100 times or more

SKIP = [
  ' / HTTP/',
  ' /robots.txt ',
  ' /sitemap.xml ',
  ' /.well-known/security.txt ',
  ' /favicon.ico ',
  ' /clientaccesspolicy.xml ',
  ' "" 400 0 ',
  ' "-" 400 0 ',
  'apple-touch'
].freeze

removed = 0

ARGF.each do |line|
  ##
  # This is probably the status code (it could be the respose
  # size though) so we will skip these are a precaution
  ##
  next if line.include?(' 200 ')

  ok = true

  SKIP.each do |pattern|
    next unless line.include?(pattern)

    ok = false
    removed += 1
    break
  end

  puts line if ok
end

STDERR.puts "Removed #{removed} lines"
