require './test/helper'
require 'paperclip/has_attached_file'

class HasAttachedFileTest < Test::Unit::TestCase
  context '#define_on' do
    should 'define a setter on the class object' do
      assert_adding_attachment('avatar').defines_method('avatar=')
    end

    should 'define a getter on the class object' do
      assert_adding_attachment('avatar').defines_method('avatar')
    end

    should 'define a query on the class object' do
      assert_adding_attachment('avatar').defines_method('avatar?')
    end

    should 'flush errors as part of validations' do
      assert_adding_attachment('avatar').defines_validation
    end

    should 'register the attachment with Paperclip::Tasks' do
      assert_adding_attachment('avatar').registers_with_tasks
    end

    should 'define an after_save callback' do
      assert_adding_attachment('avatar').defines_callback('after_save')
    end

    should 'define a before_destroy callback' do
      assert_adding_attachment('avatar').defines_callback('before_destroy')
    end

    should 'define an after_destroy callback' do
      assert_adding_attachment('avatar').defines_callback('after_destroy')
    end

    should 'define the Paperclip-specific callbacks' do
      assert_adding_attachment('avatar').defines_callback('define_paperclip_callbacks')
    end
  end

  private

  def assert_adding_attachment(attachment_name)
    AttachmentAdder.new(attachment_name)
  end

  class AttachmentAdder
    include Mocha::API
    include Test::Unit::Assertions

    def initialize(attachment_name)
      @attachment_name = attachment_name
    end

    def defines_method(method_name)
      a_class = stub_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {})

      assert_received(a_class, :define_method) do |expect|
        expect.with(method_name)
      end
    end

    def defines_validation
      a_class = stub_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {})

      assert_received(a_class, :validates_each) do |expect|
        expect.with(@attachment_name)
      end
    end

    def registers_with_tasks
      a_class = stub_class
      Paperclip::Tasks::Attachments.stubs(:add)

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {size: 1})

      assert_received(Paperclip::Tasks::Attachments, :add) do |expect|
        expect.with(a_class, @attachment_name, {size: 1})
      end
    end

    def defines_callback(callback_name)
      a_class = stub_class

      Paperclip::HasAttachedFile.define_on(a_class, @attachment_name, {})

      assert_received(a_class, callback_name.to_sym)
    end

    private

    def stub_class
      stub('class',
           validates_each: nil,
           define_method: nil,
           after_save: nil,
           before_destroy: nil,
           after_destroy: nil,
           define_paperclip_callbacks: nil,
           name: 'Billy')
    end
  end
end