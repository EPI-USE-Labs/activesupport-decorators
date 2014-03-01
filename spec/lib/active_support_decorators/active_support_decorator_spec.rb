require 'spec_helper'

describe ActiveSupportDecorators do

  before :each do
    # Clear class from Ruby environment.
    ActiveSupport::Dependencies.clear
    Object.send(:remove_const, :Pet) if defined?(Pet)
  end

  describe 'when configuring a decorator dependency' do
    before :all do
      original_path = File.join(File.dirname(__FILE__), 'support/originals')
      decorator_path = File.join(File.dirname(__FILE__), 'support/decorators')
      ActiveSupportDecorators.clear
      ActiveSupportDecorators.add(original_path, decorator_path)
    end

    context 'and requiring the original file as .rb' do
      it 'it loads the decorator file after loading the original' do
        path = File.join(File.dirname(__FILE__), 'support/originals/pet.rb')
        ActiveSupport.require_or_load(path)

        Pet.new.owner.should eq('Mr. Robinson')
      end
    end

    context 'and requiring the original file' do
      it 'it loads the decorator file after loading the original' do
        path = File.join(File.dirname(__FILE__), 'support/originals/pet')
        ActiveSupport.require_or_load(path)

        Pet.new.owner.should eq('Mr. Robinson')
      end
    end

    context 'and requiring the decorator file' do
      it 'it loads the original file first' do
        path = File.join(File.dirname(__FILE__), 'support/decorators/pet_decorator')
        ActiveSupport.require_or_load(path)

        Pet.new.owner.should eq('Mr. Robinson')
      end
    end
  end

  describe 'when not using activesupport-decorators' do
    before :all do
      ActiveSupportDecorators.clear
    end

    it 'should not automatically load decorators' do
      pet_path = File.join(File.dirname(__FILE__), 'support/originals/pet')
      ActiveSupport.require_or_load(pet_path)

      expect { Pet.new.owner }.to raise_error
    end
  end

end
