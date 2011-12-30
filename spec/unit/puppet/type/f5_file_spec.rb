#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_file
res_type = Puppet::Type.type(res_type_name)

describe res_type do

  let(:path) { '/tmp/f5_test_file' }
  let(:f5_file) { described_class.new(:path => path, :catalog => catalog) }
  let(:provider) { f5_file.provider }
  let(:catalog) { Puppet::Resource::Catalog.new }

  describe "path parameter" do
    it "should reject relative path" do
      expect {
        f5_file[:path] = 'test_file'
      }.should raise_error(/file path must be absolute path/)
    end

    it "should accept absolute path" do
      f5_file[:path] = '/tmp/test_file'
      f5_file[:path].should == '/tmp/test_file'
    end
  end

  describe "content attribute" do
    it "default to ''" do
      f5_file[:content].should == 'md5(d41d8cd98f00b204e9800998ecf8427e)'
    end

    it "should calculate md5 checksum" do
      f5_file[:content] = 'hello world!'
      f5_file[:content].should == 'md5(fc3ff98e8c6a0d3087d515c0473f8677)'
    end

    it "should set real_content to content value" do
      f5_file[:content] = 'hello world!'
      f5_file[:real_content].should == 'hello world!'
    end
  end
end
