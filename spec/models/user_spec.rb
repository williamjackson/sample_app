require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
      }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require a valid email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    valid_addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    valid_addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should not accept invalid email addresses" do
    invalid_addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    invalid_addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject identical email addresses up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  describe "passwrod validations" do
    
    it "should require a password" do
      no_password_user = User.new(@attr.merge(:password => "",
                                              :password_confirmation => ""))
      no_password_user.should_not be_valid
                                              
    end
    
    it "should require a matching password confirmation" do
    no_matching_password_user = User.new(@attr.merge(:password => "william"))
    no_matching_password_user.should_not be_valid
    end
    
    it "should reject short passwords" do
      short_password_user = User.new(@attr.merge(:password => "foo",
          :confirmation_password => "foo"))
      short_password_user.should_not be_valid
    end
    
    it "should reject long passwords" do
      long_password_user = User.new(@attr.merge(:password => "a" * 41,
          :confirmation_password => "a" * 41))
      long_password_user.should_not be_valid
    end
  end
  
  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end
  
    describe "authenticate method" do
      it "should return nil when the email/password combination is invalid" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end
    
      it "should return nil when no user exists with the given email address" do
        wrong_email_user = User.authenticate("123@frf.com", @attr[:password])
        wrong_email_user.should be_nil
      end
    
      it "should return the user object itself on success" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end
end
