# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::ReportSender do
  let(:config) do
    c = {
      smtp: {
        enabled: true,
        server: 'smtp.server',
        port:   25,
        from: 'from@example.com',
        to:   'to@example.com'
      }
    }
    c.extend(HashWithMethodAccess)
    c.extend(HashWithConstraints)
    c
  end
  let(:sender) { Xenuti::ReportSender.new(config) }

  describe '#initialize' do
    it 'should accept correct config' do
      expect(sender).to be_a(Xenuti::ReportSender)
    end

    it 'should verify server is present and is a String' do
      config.smtp.server = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config.smtp.server = :servername
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end

    it 'should verify port is present and is an Integer' do
      config.smtp.port = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config.smtp.port = :port
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end

    it 'should verify from is present and is an email address' do
      config.smtp.from = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config.smtp.from = 'foo@bar@baz'
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end

    it 'should verify to is present and is an email address' do
      config.smtp.to = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config.smtp.to = 'foo@bar@baz'
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end
  end

  describe '#mail_address?' do
    it 'should return true for valid email address' do
      expect(Xenuti::ReportSender.mail_address? 'test@foo.com').to be_true
      expect(Xenuti::ReportSender.mail_address? 'Mail@Address.IO').to be_true
    end

    it 'should return false for invalid email address' do
      expect(Xenuti::ReportSender.mail_address? 'mail').to be_false
      expect(Xenuti::ReportSender.mail_address? 'test@foo@bar.com').to be_false
    end
  end
end
