# encoding: utf-8

class Nanoc::CLI::Commands::CompileTest < Nanoc::TestCase

  def test_profiling_information
    in_site do
      File.write('content/foo.md', 'hai')
      File.write('content/bar.md', 'hai')
      File.write('content/baz.md', 'hai')

      File.open('Rules', 'w') do |io|
        io.write "compile '/**/*' do\n"
        io.write "  filter :erb\n"
        io.write "  if item.binary?\n"
        io.write "    write item.identifier\n"
        io.write "  else\n"
        io.write "    write item.identifier.with_ext('html')\n"
        io.write "  end\n"
        io.write "end\n"
        io.write "\n"
        io.write "layout '/**/*', :erb\n"
      end

      Nanoc::CLI.run %w( compile --verbose )
    end
  end

  def test_setup_and_teardown_listeners
    in_site do
      test_listener_class = Class.new(::Nanoc::CLI::Commands::Compile::Listener) do
        def start ; @started = true ; end
        def stop  ; @stopped = true ; end
        def started? ; @started ; end
        def stopped? ; @stopped ; end
      end

      options = {}
      arguments = []
      cmd = nil
      listener_classes = [ test_listener_class ]
      cmd_runner = Nanoc::CLI::Commands::Compile.new(
        options, arguments, cmd, :listener_classes => listener_classes)

      cmd_runner.run

      listeners = cmd_runner.send(:listeners)
      assert listeners.size == 1
      assert listeners.first.started?
      assert listeners.first.stopped?
    end
  end

end
