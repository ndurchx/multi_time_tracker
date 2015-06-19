# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

def assert_change_in_delta(expression, delta=0, message=nil, &block)
  expressions = Array(expression)

  exps = expressions.map { |e|
    e.respond_to?(:call) ? e : lambda { eval(e, block.binding) }
  }
  before = exps.map { |e| e.call }

  yield

  expressions.zip(exps).each_with_index do |(code, e), i|
    error  = "Expected #{code.inspect} to change around #{delta} but |#{before[i]} - #{e.call}| > #{delta} holds true"
    error  = "#{message}.\n#{error}" if message
    assert ((before[i] - e.call).abs <= delta), error
  end
end