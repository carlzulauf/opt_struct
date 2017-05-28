require "bundler/setup"
require "active_model"
require "pry"
require "benchmark/ips"
require "ostruct"

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "opt_struct"

module Distance
  def distance(point)
    (self.x - point.x).abs + (self.y - point.y).abs
  end
end

class Point
  include Distance
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class PointWithOptStructClass < OptStruct.new(:x, :y)
  include Distance
end

class PointWithOptStructModule
  include OptStruct
  include Distance
  expect_arguments :x, :y
end

class PointWithOptStructBuilder
  include OptStruct.build(:x, :y)
  include Distance
end

class PointOptStructRequiredKeys < OptStruct.new
  required :x, :y
  include Distance
end

class PointWithStruct < Struct.new(:x, :y)
  include Distance
end

class PointWithOpenStruct < OpenStruct
  include Distance
end

class PointWithActiveModel
  include ActiveModel::Model
  include Distance
  attr_accessor :x, :y
end

class PointWithHash
  include Distance
  attr_reader :hash

  def initialize(**hash)
    @hash = hash
  end

  def x
    hash[:x]
  end

  def y
    hash[:y]
  end
end

Benchmark.ips do |ips|
  [
    Point,
    PointWithOptStructClass,
    PointWithOptStructModule,
    PointWithOptStructBuilder,
    PointWithStruct,
  ].each do |klass|
    ips.report("#{klass}:regular-args") do
      pos1 = klass.new(2, 3)
      pos2 = klass.new(3, 4)
      raise "wrong answer with #{klass.to_s}" unless pos1.distance(pos2) == 2
    end
  end
  [
    PointWithOpenStruct,
    PointWithActiveModel,
    PointWithOptStructClass,
    PointWithOptStructModule,
    PointWithOptStructBuilder,
    PointOptStructRequiredKeys,
    PointWithHash,
  ].each do |klass|
    ips.report("#{klass}:hash-args") do
      pos1 = klass.new(x: 2, y: 3)
      pos2 = klass.new(x: 3, y: 4)
      raise "wrong answer with #{klass.to_s}" unless pos1.distance(pos2) == 2
    end
  end
end
