require 'spec_helper'

describe ActiveSupportDecorators do

  before :each do
    # Clear class from Ruby/Rails environment.
    ActiveSupportDecorators.paths.clear
    ActiveSupport::Dependencies.loaded.clear
    Object.send(:remove_const, :Pet) if defined?(Pet)
  end

  describe 'when configuring a decorator path' do
    before :each do
      ActiveSupportDecorators.stub(:all_autoload_paths) do
        [File.join(File.dirname(__FILE__), 'support', 'originals')]
      end

      ActiveSupportDecorators.paths.clear
      ActiveSupportDecorators.paths << File.join(File.dirname(__FILE__), 'support', 'decorators')
    end

    it 'it loads the decorator file after loading the original without const_path' do
      path = File.join(File.dirname(__FILE__), 'support', 'originals', 'pet')
      ActiveSupport::Dependencies.require_or_load(path)

      Pet.new.owner.should eq('Mr. Robinson')
    end

    it 'it loads the decorator file after loading the original with const_path' do
      path = File.join(File.dirname(__FILE__), 'support', 'originals', 'pet')
      ActiveSupport::Dependencies.require_or_load(path, 'Pet')

      Pet.new.owner.should eq('Mr. Robinson')
    end
  end

  describe 'when not using activesupport-decorators' do
    before :all do
      ActiveSupportDecorators.paths.clear
    end

    it 'should not automatically load decorators' do
      path = File.join(File.dirname(__FILE__), 'support', 'originals', 'pet')
      ActiveSupport::Dependencies.require_or_load(path)

      expect { Pet.new.owner }.to raise_error
    end
  end

end
