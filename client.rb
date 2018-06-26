require 'net/ping'
require 'net/ssh'

# Client class
class Client
  attr_accessor :name
  attr_accessor :host
  attr_accessor :user
  attr_accessor :pass
  attr_accessor :port

  def initialize(client)
    @name = client[:name]
    @host = client[:host]
    @user = client[:user]
    @pass = client[:pass]
    @port = client[:port]
  end

  def show
    "---
    name: #{@name}
    host: #{@host}
    user: #{@user}
    port: #{@port}"
  end

  def exec(command)
    Net::SSH.start(@host, @user, password: @pass, port: @port) do |ssh|
      ssh.exec!(command)
    end
  end

  def ping?
    client = Net::Ping::External.new(@host)
    client.ping?
  end
end
