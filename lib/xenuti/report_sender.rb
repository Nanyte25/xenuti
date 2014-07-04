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

  # rubocop:disable CyclomaticComplexity
  # rubocop:disable MethodLength
  def initialize(config)
    self.config = config
    fail 'SMTP is disabled.' unless config.smtp.enabled
    config.verify do
      fail unless smtp.server.is_a? String
      fail unless smtp.port.is_a? Integer
      fail unless Xenuti::ReportSender.mail_address? smtp.from
      # smpt.to can be either mail address or Array of mail addresses
      if smtp.to.is_a?(Array)
        smtp.to.each do |e|
          fail unless Xenuti::ReportSender.mail_address?(e)
        end
      else
        fail unless Xenuti::ReportSender.mail_address?(smtp.to)
      end
    end
  end
  # rubocop:enable MethodLength
  # rubocop:enable CyclomaticComplexity

  def send(report_content)
    options = { address: config.smtp.server, port: config.smtp.port }
    config.smtp.to.is_a?(Array) ? to = config.smtp.to : to = [config.smtp.to]
    to.each do |mail_to|
      mail = compose_mail_to(mail_to, report_content)
      mail.delivery_method :smtp, options
      mail.deliver!
    end
  end

  def compose_mail_to(mail_to, content)
    mail = Mail.new
    mail.to(mail_to)
    mail.from(config.smtp.from)
    mail.subject("[Xenuti] Results for #{config.general.name}")
    mail.body(content)
    mail
  end
end
