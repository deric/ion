require 'redis'
require 'nest'
require 'text'

module Ion
  PREFIX = File.join(File.dirname(__FILE__), 'ion')

  autoload :Stringer, "#{PREFIX}/stringer"
  autoload :Options,  "#{PREFIX}/options"
  autoload :Search,   "#{PREFIX}/search"
  autoload :Entity,   "#{PREFIX}/entity"
  autoload :Index,    "#{PREFIX}/index"
  autoload :Indices,  "#{PREFIX}/indices"

  InvalidIndexType = Class.new(StandardError)

  def self.redis
    @redis || key.redis
  end

  # Connects to a certain Redis server.
  def self.connect(to)
    @redis = Redis.connect(to)
  end

  def self.key
    @key ||= if @redis
      Nest.new('Ion', @redis)
    else
      Nest.new('Ion')
    end
  end

  # Returns a new temporary key.
  def self.volatile_key(ttl=30)
    k = key['~'][rand.to_s]
    k.expire ttl  if ttl > 0
    k
  end

  # Redis helper stuff
  # Probably best to move this somewhere

  # Combines multiple set keys.
  def self.union(keys)
    return keys.first  if keys.size == 1

    results = Ion.volatile_key
    keys.each { |key| results.sunionstore results, key }
    results
  end

  # Finds the intersection in multiple set keys.
  def self.intersect(keys)
    return keys.first  if keys.size == 1

    results = Ion.volatile_key
    results.sunionstore keys.first
    keys[1..-1].each { |key| results.sinterstore results, key }
    results
  end
end
