require 'spec_helper'

describe "user pages" do
  
  subject { page }

  describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All users') }
    it { should have_content('All users') }

    describe "pagination" do
      before(:all) { 30.times { |n| FactoryGirl.create(:user) } }
      after(:all) { User.delete_all }
    
      it { should have_selector('div.pagination') }
      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end
  end

  describe "sign up" do
    before { visit signup_path }
    let(:submit) { 'Create my account' }

    describe "with invalid register infomation" do
      it "should not register" do
        expect { click_button(submit) }.not_to change(User, :count)
      end

      describe "after submition" do
        before { click_button submit }
        it { should have_title("Sign up") }
        it { should have_content("error") }
      end
    end

    describe "with valid register infomation" do
      before do
        fill_in "Name",       with: "Example user"
        fill_in "Email",      with: "user@example.com"
        fill_in "Password",   with: "foobar"
        fill_in "Confirm",    with: "foobar"
      end
      
      it "should register" do
        expect do
          click_button(submit)
        end.to change(User, :count).by(1)
      end

      describe "after register new user" do
        before { click_button(submit) }
        let(:user) { User.find_by(email: "user@example.com") }
        
        it { should have_link('Sign out') }
        it { should have_title(user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
      end
    end

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }
  	it { should have_content(user.name) }
  	it { should have_title(user.name) }
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_content('Update your profile') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
      it { should have_title('Edit user') }
    end

    describe "with invalid infomation" do
      before { click_button 'Save change' }

      it { should have_content 'error' }
    end

    describe "with valid infomation" do
      let(:new_name) { 'New name' }
      let(:new_email) { 'new@exmaple.com' }

      before do
        fill_in 'Name',             with: new_name
        fill_in 'Email',            with: new_email
        fill_in 'Password',         with: user.password
        fill_in 'Confirm',          with: user.password
        click_button 'Save change'
      end

      it { should have_title('New name') }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { expect(user.reload.name).to eq new_name }
      specify { expect(user.reload.email).to eq new_email }
    end
  end
end
