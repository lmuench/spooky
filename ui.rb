require_relative 'client.rb'
require_relative 'server.rb'
require 'tty-prompt'
require 'tty-screen'
require 'tty-spinner'

# Command line interface
class UI
  def initialize
    @server = Server.new
    @prompt = TTY::Prompt.new
    @choice = :choice
    @screen = TTY::Screen.new
    clear
    run
  end

  def run
    loop do
      @choice = select_task
      return if @choice == :quit
      clear
      send(@choice)
    end
  end

  def select_task
    @prompt.select('') do |menu|
      menu.page_help @server.show_names
      menu.choice 'select clients',  :select_clients
      menu.choice 'execute command', :exec
      menu.choice 'ping clients',    :ping_clients
      menu.choice 'show clients',    :show_clients
      menu.choice 'add  client',     :add_client
      menu.choice 'scan clients',    :scan_clients
      menu.choice 'quit',            :quit
    end
  end

  def select_clients
    choices = {}
    @server.all_names.each_with_index do |name, i|
      choices[name] = i
    end
    @server.select @prompt.multi_select('', choices)
  end

  def exec
    command = @prompt.ask('command:')
    puts @server.exec(command)
  end

  def ping_clients
    spinner = TTY::Spinner.new(
      '[:spinner] ',
      format: :arrow_pulse,
      clear: true
    )
    spinner.run { @server.ping_clients }
  end

  def show_clients
    puts @server.show_clients
  end

  def add_client
    name = @prompt.ask('name:')
    host = @prompt.ask('host:')
    user = @prompt.ask('user:')
    pass = @prompt.ask('pass:')
    port = @prompt.ask('port:')
    @server.add_client(name, host, user, pass, port)
  end

  def scan_clients
    @server.scan_clients
  end

  def newline(n = 1)
    puts "\n" * n
  end

  def clear
    newline @screen.height
  end
end
