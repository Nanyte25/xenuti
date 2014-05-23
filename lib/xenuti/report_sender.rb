# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'net/smtp'
require 'mail'

class Xenuti::ReportSender
  attr_accessor :config

  def self.mail_address?(address)
    /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\Z/.match address
  end

  def initialize(config)
    self.config = config
    fail 'SMTP is disabled.' unless config.smtp.enabled
    config.verify do
      fail unless smtp.server.is_a? String
      fail unless smtp.port.is_a? Integer
      fail unless Xenuti::ReportSender.mail_address? smtp.from
      fail unless Xenuti::ReportSender.mail_address? smtp.to
    end
  end

  def send(report_content)
    mail = Mail.new
    mail.to(config.smtp.to)
    mail.from(config.smtp.from)
    mail.subject("[Xenuti] Results for #{config.general.name}")
    mail.body(report_content)

    options = { address: config.smtp.server, port: config.smtp.port }
    mail.delivery_method :smtp, options
    mail.deliver!
  end
end
