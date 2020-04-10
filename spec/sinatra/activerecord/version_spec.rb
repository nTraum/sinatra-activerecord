# frozen_string_literal: true

RSpec.describe Sinatra::ActiveRecord do
  describe 'VERSION' do
    subject { described_class::VERSION }
    it { is_expected.to be_a(String) }
  end
end
