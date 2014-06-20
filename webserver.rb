# coding: utf-8
require 'webrick'
require 'rubygems'
require 'haml'

class HamlHandler < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server, name)
    super
    @script_filename = name
  end

  def do_GET(req, res)
    begin
      data = open(@script_filename){|io| io.read }
      res.body = parse_haml(data)
      res['content-type'] = 'text/html'
    rescue StandardError => ex
      raise
    rescue Exception => ex
      @logger.error(ex)
      raise HTTPStatus::InternalServerError, ex.message
    end
  end

  alias do_POST do_GET

  private
    def parse_haml(string)
      engine = Haml::Engine.new(string,
        :attr_wrapper => '"',
        :filename => @script_filename
      )
      engine.render
    end
end

WEBrick::HTTPServlet::FileHandler.add_handler("haml", HamlHandler)

args = ARGV.join(' ')
args.gsub!(%r{^http://}, '')
args = args.split(/[ :]/).compact

server = WEBrick::HTTPServer.new(
  :Port => args.pop || 8888,
  # :BindAddress => args.pop || '0.0.0.0',
  :DocumentRoot => Dir.pwd
)

trap("INT") { server.shutdown }

server.start