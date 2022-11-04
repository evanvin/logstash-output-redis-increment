# encoding: utf-8
require "logstash/outputs/base"

# An redis-increment output that does nothing.
class LogStash::Outputs::RedisIncrement < LogStash::Outputs::Base
  config_name "redis-increment"

  public
  def register
  end # def register

  public
  def receive(event)
    return "Event received"
  end # def event
end # class LogStash::Outputs::RedisIncrement
