require 'test_helper'

class RecipientMailerTest < ActionMailer::TestCase
  test "recipient_mailer" do
    @expected.subject = 'RecipientMailer#recipient_mailer'
    @expected.body    = read_fixture('recipient_mailer')
    @expected.date    = Time.now

    assert_equal @expected.encoded, RecipientMailer.create_recipient_mailer(@expected.date).encoded
  end

end
