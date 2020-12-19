require 'fileutils'

test = <<-TEST
suggestions = $gtk.suggest_autocompletion index: 45, text: <<-S
require 'app/game.rb'

def tick args
  args.
  args.inputs.keyboard.key_up.backspace
  args.gtk.suppress_mailbox = false
  $game ||= Game.new
  $game.args = args
  $game.tick
end
S

$gtk.write_file 'app/autocomplete.txt', suggestions.join("\n")
TEST

begin
`rm -rf ./mailbox-processed/`
rescue
end

begin
`rm ./autocomplete.txt 2> /dev/null`
rescue
end

# FOR TESTING
# begin
# `rm ./mailbox.txt 2> /dev/null`
# rescue
# end
# File.write './mailbox.txt', test

puts "========"

if !File.exist? './mailbox.txt'
else
  contents = File.read './mailbox.txt'
  `rm ./mailbox.txt`
  File.write './mailbox.rb', contents
  timeout = 480
  while timeout > 0
    sleep 0.001
    timeout -= 1
    if File.exist? './autocomplete.txt'
      puts (File.read './autocomplete.txt')
      timeout = 0
    end
  end
end

puts "========"
puts "done"
