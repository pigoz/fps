#!/usr/bin/env ruby
# frozen_string_literal: true

cmd = 'ffprobe -v 0 -of csv=p=0 -select_streams 0 -show_entries stream=r_frame_rate'
fps = `#{cmd} #{ARGV.first}`.strip.split('/').map { |x| Float(x) }.reduce(:/)
switcher = File.expand_path('./set.swift', __dir__)

def is(fps, expected)
  fps >= expected - 0.5 && fps <= expected + 0.5
end

puts `#{switcher} 24` if is(fps, 24)
puts `#{switcher} 30` if is(fps, 30)
