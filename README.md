# company-dragonruby
`company-mode` backend from DragonRuby.

[Here](https://youtu.be/TNhHiSXPEu8) is a video of it in action.

For this to work, you need to enable DragonRuby Game Toolkit's mailbox:

```ruby
def tick args
  args.gtk.suppress_mailbox = false
end
```
