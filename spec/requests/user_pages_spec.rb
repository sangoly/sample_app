require 'spec_helper'

describe "user pages" do
  
  subject { page }

  describe "sign up" do
    before { visit signup_path }
    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end
end