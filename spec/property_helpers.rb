require 'property'


module PropertyHelpers
  shared_examples_for 'Property' do
    before(:each) do
      Property.clear
    end

    after(:each) do
      Property.clear
    end
  end
end
