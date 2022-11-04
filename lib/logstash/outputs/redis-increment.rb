# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

# An redis output that does nothing.
class LogStash::Outputs::Redis < LogStash::Outputs::Base
  config_name "redis-increment"

  default :codec, "json"

  # The hostname of your Redis server.
  config :host, :validate => :string, :default => "127.0.0.1:6379"

  # Password to authenticate with. There is no authentication by default.
  config :password, :validate => :password

  # The Redis database number.
  config :db, :validate => :number, :default => 0

  # Connection timeout
  config :timeout, :validate => :number, :default => 5

  # Interval for reconnecting to failed Redis connections
  config :reconnect_interval, :validate => :number, :default => 1

  # The name of a redis key
  config :key, :validate => :string, :required => true

  # The name of a redis key
  config :cluster, :validate => :boolean, :default => true

  public
  def register
    require "redis"
    @redis = nil
    @codec.on_event(&method(:send_to_redis))
  end # def register

  public
  def receive(event)
    begin
      @codec.encode(event)
    rescue LocalJumpError
      # This LocalJumpError rescue clause is required to test for regressions
      # for https://github.com/logstash-plugins/logstash-output-redis/issues/26
      # see specs. Without it the LocalJumpError is rescued by the StandardError
      raise
    rescue StandardError => e
      @logger.warn("Error encoding event", :exception => e,
                   :event => event)
    end
  end # def event

  private
  def connect
    @current_host, @current_port = @host.split(':')

    if @cluster
      node_list = Array.new
      node_list << "redis://#{@host}"
      Redis.new(cluster:node_list)
    else
        params = {
          :host => @current_host,
          :port => @current_port,
          :timeout => @timeout,
          :db => @db,
        }
        @logger.debug("connection params", params)

        if @password
          params[:password] = @password.value
        end

        Redis.new(params)
    end
  end #def connect

  # A string used to identify a Redis instance in log messages
  def identity
    "redis://#{@password}@#{@current_host}:#{@current_port}/#{@db} #{@key}"
  end

  def send_to_redis(event, payload)
    key = event.sprintf(@key)
    begin
        @redis ||= connect
        @redis.incr(key)
      rescue => e
        @logger.warn("Failed to increment event to Redis", :event => event,
                     :identity => identity, :exception => e,
                     :backtrace => e.backtrace)
        sleep @reconnect_interval
        @redis = nil
        retry
      end
  end #def send_to_redis
end # class LogStash::Outputs::Redis