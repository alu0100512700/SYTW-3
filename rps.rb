require 'rack/request'
require 'rack/response'
require 'haml'
require 'rack'

module RockPaperScissors
    class App 
  
      def initialize(app = nil)
        @app = app
        @content_type = :html
        @defeat = {'rock' => 'scissors', 'paper' => 'rock', 'scissors' => 'paper'}
        @throws = @defeat.keys
        @choose = @throws.map { |x| 
           %Q{ <li><a href="/?choice=#{x}">#{x}</a></li> }     #Puedes meter en haml con %li
        }.join("\n")
        @choose = "<p>\n<ul>\n#{@choose}\n</ul>\n</p>"				#Puedes añadir en haml con %p 
      end
  
      def call(env)
        req = Rack::Request.new(env)
  
        req.env.keys.sort.each { |x| puts "#{x} => #{req.env[x]}" }
  
        computer_throw = @throws.sample
        player_throw = req.GET["choice"]
        answer = if !@throws.include?(player_throw)
            ""
          elsif player_throw == computer_throw
            "Result: You tied with the computer"
          elsif computer_throw == @defeat[player_throw]
            "Result: Nicely done; #{player_throw} beats #{computer_throw}"
          else
            "Result: Ouch; #{computer_throw} beats #{player_throw}. Better luck next time!"
          end

        engine = Haml::Engine.new File.open("views/index.html.haml").read  
        res = Rack::Response.new

        res.write engine.render({},
          :answer => answer,
          :choose => @choose,
          #:throws => @throws
          #:computer_throw => computer_throw,
          #:player_throw => player_throw,
          #:aux => aux
        )
        res.finish 
      end # call
    end   # App
  end     # RockPaperScissors

  if $0 == __FILE__
    require 'rack/showexceptions'
    Rack::Server.start(
      :app => Rack::ShowExceptions.new(
                Rack::Lint.new(
                  RockPaperScissors::App.new)),
      :Port => 9292,
      :server => 'thin'
    )
  end
