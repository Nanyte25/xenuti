# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'spec_helper'

describe Xenuti::ReportSender do
  let(:config) do
    c = {
      'report' => {
        'send_mail' => true,
        'server'    => 'smtp.server',
        'port'      => 25,
        'from'      => 'from@example.com',
        'to'        => 'to@example.com'
      }
    }
    c.extend(HashWithConstraints)
    c
  end
  let(:sender) { Xenuti::ReportSender.new(config) }

  describe '#initialize' do
    it 'should accept correct config' do
      expect(sender).to be_a(Xenuti::ReportSender)
    end

    it 'should verify server is present and is a String' do
      config['report']['server'] = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config['report']['server'] = :servername
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end

    it 'should verify port is present and is an Integer' do
      config['report']['port'] = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config['report']['port'] = :port
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end

    it 'should verify from is present and is an email address' do
      config['report']['from'] = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config['report']['from'] = 'foo@bar@baz'
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end

    it 'should verify to is present and is an email address' do
      config['report']['to'] = nil
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
      config['report']['to'] = 'foo@bar@baz'
      expect { Xenuti::ReportSender.new(config) }.to raise_error RuntimeError
    end
  end

  describe '#mail_address?' do
    it 'should return true for valid email address' do
      expect(Xenuti::ReportSender.mail_address? 'test@foo.com').to be true
      expect(Xenuti::ReportSender.mail_address? 'Mail@Address.IO').to be true
    end

    it 'should return false for invalid email address' do
      expect(Xenuti::ReportSender.mail_address? 'mail').to be false
      expect(Xenuti::ReportSender.mail_address? 'test@foo@bar.com').to be false
    end
  end
end
