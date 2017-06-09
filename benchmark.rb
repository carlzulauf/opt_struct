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

class PointWithUnusedOptions
  include Distance
  attr_reader :x, :y

  DEFAULTS = {foo: "bar"}

  def initialize(x, y, **options)
    @x = x
    @y = y
    @options = DEFAULTS.merge(options)
  end
end

class PointOptStructClass < OptStruct.new(:x, :y)
  include Distance
end

class PointOptStructModule
  include OptStruct
  include Distance
  expect_arguments :x, :y
end

class PointOptStructBuilder
  include OptStruct.build(:x, :y)
  include Distance
end

class PointOptStructRequiredKeys < OptStruct.new
  include Distance
  required :x, :y
end

class PointOptStructOptionalKeys < OptStruct.new
  include Distance
  options :x, :y
end

PointOptStructRequiredBlock = OptStruct.new do
  include Distance
  required :x, :y
end

class PointOptStructDefineMethodAccessors
  include OptStruct
  include Distance

  class << self
    def option_reader(*keys)
      keys.each do |key|
        define_method(key) { options[key] }
      end
    end

    def option_writer(*keys)
      keys.each do |key|
        define_method("#{key}=") { |value| option[key] = value }
      end
    end
  end

  options :x, :y
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

class PointWithHashAndDefaults
  include Distance
  attr_reader :hash

  DEFAULTS = {foo: "bar"}

  def initialize(**hash)
    @hash = DEFAULTS.merge(hash)
  end

  def x
    hash[:x]
  end

  def y
    hash[:y]
  end
end

class PointWithAttributeArray
  include Distance
  attr_reader :hash
  attr_reader :attributes

  DEFAULTS = {foo: "bar"}

  def initialize(*attributes, **hash)
    @attributes = attributes
    @attributes << hash.delete(:x) if @attributes.length < 1
    @attributes << hash.delete(:y) if @attributes.length < 2
    @hash = DEFAULTS.merge(hash)
  end

  def x
    @attributes[0]
  end

  def y
    @attributes[1]
  end
end

class PointWithAttributeHash
  include Distance
  attr_reader :hash
  attr_reader :attributes

  DEFAULTS = {foo: "bar"}

  def initialize(*attributes, **hash)
    @attributes = {}
    [:x, :y].each_with_index do |k, i|
      if attributes.length > i
        @attributes[k] = attributes[i]
      else
        @attributes[k] = hash.delete(k)
      end
    end
    @hash = DEFAULTS.merge(hash)
  end

  def x
    @attributes[:x]
  end

  def y
    @attributes[:y]
  end
end

arg_klasses = [
  Point,
  PointWithUnusedOptions,
  PointOptStructClass,
  PointOptStructModule,
  PointOptStructBuilder,
  PointWithStruct,
  PointWithAttributeArray,
  PointWithAttributeHash,
]

hash_klasses = [
  PointWithOpenStruct,
  PointWithActiveModel,
  PointOptStructClass,
  PointOptStructModule,
  PointOptStructBuilder,
  PointOptStructRequiredKeys,
  PointOptStructOptionalKeys,
  PointOptStructRequiredBlock,
  PointOptStructDefineMethodAccessors,
  PointWithHash,
  PointWithHashAndDefaults,
  PointWithAttributeArray,
  PointWithAttributeHash,
]

Benchmark.ips do |ips|
  arg_klasses.each do |klass|
    ips.report("#{klass}:arg-allocations") do
      pos1 = klass.new(2, 3)
      pos2 = klass.new(3, 4)
      raise "wrong answer with #{klass.to_s}" unless pos1.distance(pos2) == 2
    end
  end
  ips.compare!
end

Benchmark.ips do |ips|
  hash_klasses.each do |klass|
    ips.report("#{klass}:hash-allocations") do
      pos1 = klass.new(x: 2, y: 3)
      pos2 = klass.new(x: 3, y: 4)
      raise "wrong answer with #{klass.to_s}" unless pos1.distance(pos2) == 2
    end
  end
  ips.compare!
end

Benchmark.ips do |ips|
  hash_klasses.each do |klass|
    i = klass.new(x: 4, y: 5)
    ips.report("#{klass}:hash-access") do
      1000.times { i.x; i.y }
    end
  end
  ips.compare!
end
