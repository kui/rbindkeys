# a repro code (see repro_freeze_bug.rb)

t = Thread.new do
  select [], [], [], 1
end


file = open '/dev/uinput', 'w'

# file.write 'foo' # ok
file.syswrite 'foo' # block

t.join
