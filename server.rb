require_relative 'client.rb'
require 'yaml'

# Control server
class Server
  def initialize
    @clients = []
    @selected = []
    scan_clients
  end

  def spooky_path
    File.dirname(__FILE__)
  end

  def scan_clients
    @clients = []
    Dir.glob("#{spooky_path}/clients/*.yml") do |yml|
      data = YAML.load_file(yml)
      client = Client.new(data)
      @clients << client
    end
  end

  def add_client(name, host, user, pass, port)
    data = {
      name: name,
      host: host,
      user: user,
      pass: pass,
      port: port
    }
    client = Client.new(data)
    yaml = data.to_yaml
    File.write("#{spooky_path}/clients/#{name}.client", yaml)
    @clients << client
  end

  def show_clients
    info = []
    @selected.each do |client|
      info << client.show
    end
    info
  end

  def select(clients)
    @selected = []
    clients.each do |i|
      @selected << @clients[i]
    end
  end

  def show_names
    selected_clients = 'selected:'
    @selected.each do |client|
      selected_clients << " #{client.name}"
    end
    selected_clients
  end

  def exec(command)
    output = []
    @selected.each do |client|
      client_output = client.exec(command)
      output << "#{client.name}\n#{client_output}\n"
    end
    output
  end

  def ping_clients
    threads = []
    @selected.each_with_index do |client, i|
      threads << Thread.new do
        status = client.ping? ? 'online' : 'offline'
        sleep(0.1 * i) # give spinner time to be printed
        print "#{client.name}: #{status} \n"
      end
    end
    threads.each(&:join)
  end

  def all_names
    names = []
    @clients.each do |client|
      names << client.name
    end
    names
  end
end
