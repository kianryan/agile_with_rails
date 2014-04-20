require 'test_helper'

class ErrorNotifierTest < ActionMailer::TestCase
  test "error" do
    error = Exception.new "I am an error"

    mail = ErrorNotifier.error error

    assert_equal "A Website Error Has Occured", mail.subject
    assert_equal ["admin@depot.com"], mail.to
    assert_equal ["depot@depot.com"], mail.from
    assert_match Regexp.new("I am an error"), mail.body.encoded
  end

end
