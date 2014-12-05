require "ipaddr"

module Puppet::Parser::Functions

  newfunction(:test, :type => :rvalue, :doc => <<-EOS
Returns an ip address for the given network in cidr notation

test("127.0.0.0/24") => 127.0.0.0
    EOS
  ) do |args| 

    range = IPAddr.new(args[0])
    address = range.to_string
    return address
  end
end
