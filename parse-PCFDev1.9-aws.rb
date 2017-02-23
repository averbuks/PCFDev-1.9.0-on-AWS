require 'sparkle_formation'
require 'pp'
require 'json'

SparkleFormation.sparkle_path = File.join(File.dirname(__FILE__), 'cloudformation')

puts JSON.pretty_generate(
  SparkleFormation.compile(
    File.join(
      File.dirname(__FILE__),
      'cloudformation/pcfdev-1.9.0-aws.rb'
    )
  )
)