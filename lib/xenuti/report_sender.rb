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
    fail 'SMTP is disabled.' unless config[:report][:send_mail]
    config.verify do
      fail unless self[:report][:server].is_a? String
      fail unless self[:report][:port].is_a? Integer
      fail unless Xenuti::ReportSender.mail_address? self[:report][:from]
      # smpt.to can be either mail address or Array of mail addresses
      if self[:report][:to].is_a?(Array)
        self[:report][:to].each do |e|
          fail unless Xenuti::ReportSender.mail_address?(e)
        end
      else
        fail unless Xenuti::ReportSender.mail_address?(self[:report][:to])
      end
    end
  end
  # rubocop:enable MethodLength
  # rubocop:enable CyclomaticComplexity

  def send(report_content)    
    options = { address: config[:report][:server], \
                port: config[:report][:port] }
    if config[:report][:to].is_a?(Array)
      to = config[:report][:to]
    else
      to = [config[:report][:to]]
    end
    to.each do |mail_to|
      mail = compose_mail_to(mail_to, report_content)
      mail.delivery_method :smtp, options
      mail.deliver!
    end
  end

  def compose_mail_to(mail_to, content)
    mail = Mail.new
    mail.to(mail_to)
    mail.from(config[:report][:from])
    mail.subject("[Xenuti] Results for #{config[:general][:name]}")
    mail.body(content)
    mail
  end
end
