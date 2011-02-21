require 'test_helper'

class SendPublicMailerTest < ActionMailer::TestCase
  test "send_public_mailer" do
    @expected.subject = 'SendPublicMailer#send_public_mailer'
    @expected.body    = read_fixture('send_public_mailer')
    @expected.date    = Time.now

    assert_equal @expected.encoded, SendPublicMailer.create_send_public_mailer(@expected.date).encoded
  end

end
