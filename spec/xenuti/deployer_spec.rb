# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.
require 'tempfile'
require 'ruby_util/string'

describe Xenuti::Deployer do
  before(:all) do
    @host = 'host.example.com'
    @username = 'username'
    @password = 'password'
    @variables = "H=#{@host}, U=#{@username}, P=#{@password}"
    @deploy_dir = Dir.mktmpdir
    @script = File.join(@deploy_dir, 'script')
    @output = File.join(@deploy_dir, 'output')

    c = { active_scan: {
      deploy_script: @script,
      cleanup_script: @script,
      deploy_variables: @variables,
      cleanup_variables: @variables
      } }
    @config = Xenuti::Config.from_hash(c)

    File.open(@script, 'w+') do |file|
      file.write "echo \"$H, $U, $P\" > #{@output}"
    end
    FileUtils.chmod 0755, @script
  end

  context '::deploy' do
    it 'should pass environment variables from config to script' do
      expect(Xenuti::Deployer.deploy(@config)).to be_true
      File.open(@output, 'r') do |file|
        h, u, p = file.read.split(',').map { |e| e.strip }
        expect(h).to be_eql(@host)
        expect(u).to be_eql(@username)
        expect(p).to be_eql(@password)
      end
    end
  end

  context '::cleanup' do
    it 'should pass environment variables from config to script' do
      expect(Xenuti::Deployer.cleanup(@config)).to be_true
      File.open(@output, 'r') do |file|
        h, u, p = file.read.split(',').map { |e| e.strip }
        expect(h).to be_eql(@host)
        expect(u).to be_eql(@username)
        expect(p).to be_eql(@password)
      end
    end
  end
end
