require 'rubygems'
require 'ruby-debug'

module Riot
  module AssertionMacros
    # Asserts that the result of the test equals the expected value
    #   asserts("test") { "foo" }.equals("foo")
    #   should("test") { "foo" }.equals("foo")
    def equals(expected)
      expected == actual || fail("expected #{expected.inspect}, not #{actual.inspect}")
    end

    # Asserts that the result of the test is nil
    #   asserts("test") { nil }.nil
    #   should("test") { nil }.nil
    def nil
      actual.nil? || fail("expected nil, not #{actual.inspect}")
    end

    # Asserts that the result of the test is a non-nil value. This is useful in the case where you don't want
    # to translate the result of the test into a boolean value
    #   asserts("test") { "foo" }.exists
    #   should("test") { 123 }.exists
    #   asserts("test") { "" }.exists
    #   asserts("test") { nil }.exists # This would fail
    def exists
      !actual.nil? || fail("expected a non-nil value")
    end

    # Asserts that the test raises the expected Exception
    #   asserts("test") { raise My::Exception }.raises(My::Exception)
    #   should("test") { raise My::Exception }.raises(My::Exception)
    #
    # You can also check to see if the provided message equals or matches your expectations. The message from
    # the actual raised exception will be converted to a string before any comparison is executed.
    #   asserts("test") { raise My::Exception, "Foo" }.raises(My::Exception, "Foo")
    #   asserts("test") { raise My::Exception, "Foo Bar" }.raises(My::Exception, /Bar/)
    #   asserts("test") { raise My::Exception, ["a", "b"] }.raises(My::Exception, "ab")
    def raises(expected, expected_message=nil)
      actual_error = raised && raised.original_exception
      @raised = nil
      if actual_error.nil?
        return fail("should have raised #{expected}, but raised nothing")
      elsif expected != actual_error.class
        return fail("should have raised #{expected}, not #{actual_error.class}")
      elsif expected_message && !(actual_error.message.to_s =~ %r[#{expected_message}])
        return fail("expected #{expected_message} for message, not #{actual_error.message}")
      end
      true
    end

    # Asserts that the result of the test equals matches against the proved expression
    #   asserts("test") { "12345" }.matches(/\d+/)
    #   should("test") { "12345" }.matches(/\d+/)
    def matches(expected)
      expected = %r[#{Regexp.escape(expected)}] if expected.kind_of?(String)
      actual =~ expected || fail("expected #{expected.inspect} to match #{actual.inspect}")
    end

    # Asserts that the result of the test is an object that is a kind of the expected type
    #   asserts("test") { "foo" }.kind_of(String)
    #   should("test") { "foo" }.kind_of(String)
    def kind_of(expected)
      actual.kind_of?(expected) || fail("expected kind of #{expected}, not #{actual.inspect}")
    end

    # Asserts that the result of the test is an object that responds to the given method
    #   asserts("test") { "foo" }.respond_to(:to_s)
    #   should("test") { "foo" }.respond_to(:to_s)
    def respond_to(expected)
      actual.respond_to?(expected) || fail("expected method #{expected.inspect} is not defined")
    end

    # Asserts that two arrays contain the same elements, the same number of times.
    #   asserts("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
    #   should("test") { ["foo", "bar"] }.same_elements(["bar", "foo"])
    def same_elements(expected)
      [:select, :inject, :size].each do |meth|
        [actual, expected].each do |a|
           unless a.respond_to?(meth)
             return fail("#{a.inspect} should be an array, but doesn't respond to #{meth.inspect}")
           end
        end
      end
      expected_elements = expected.inject({}) { |h,e| h[e] = expected.select { |i| i == e }.size; h }
      actual_elements = actual.inject({}) { |h,e| h[e] = actual.select { |i| i == e }.size; h }
      expected_elements == actual_elements || fail("expected elements #{expected.inspect} do not match #{actual.inspect}")
    end

    # Asserts that an instance variable is defined for the result of the assertion. Value of instance
    # variable is expected to not be nil
    #   setup { User.new(:email => "foo@bar.baz") }
    #   topic.assigns(:email)
    #
    # If a value is provided in addition to the variable name, the actual value of the instance variable
    # must equal the expected value
    #   setup { User.new(:email => "foo@bar.baz") }
    #   topic.assigns(:email, "foo@bar.baz")
    def assigns(variable, expected_value=nil)
      actual_value = actual.instance_variable_get("@#{variable}")
      return fail("expected @#{variable} to be assigned a value") if actual_value.nil?
      unless expected_value.nil? || expected_value == actual_value
        return fail(%Q[expected @#{variable} to be equal to '#{expected_value}', not '#{actual_value}'])
      end
      true
    end
  end # AssertionMacros
end # Riot

Riot::Assertion.instance_eval { include Riot::AssertionMacros }