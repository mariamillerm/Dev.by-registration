#!/usr/bin/env ruby
require 'securerandom'
require 'faker'
require 'mechanize'
require 'temp/mail'

module Account
    @agent;
    @data = {'username': "", 'password': "", 'email': ""}

    def generateUserData
        @data['username'] = Faker::Internet.user_name(Faker::Name.name_with_middle, %w(_));
        @data['email'] = @data['username'] + '@p33.org';
        @data['password'] = SecureRandom.hex(10);    
    end

    def fillInUserData
        @agent.page.forms[0]["user[username]"] = @data['username'];
        @agent.page.forms[0]["user[email]"] = @data['email'];
        @agent.page.forms[0]["user[password]"] = @data['password'];
        @agent.page.forms[0]["user[password_confirmation]"] = @data['password'];
        @agent.page.forms[0]["user_agreement"] = "true";
        @agent.page.forms[0].submit;    
    end

    def createUser
        @agent = Mechanize.new;
        @agent.get("https://dev.by/registration"); 
        Account::generateUserData; 
        Account::fillInUserData;
        sleep(4);
        Account::confirmEmail;
    end

    def output
        puts @data['username'] + ':' + @data['password'];    
    end

    def confirmEmail
        client = Temp::Mail::Client.new;
	emails = client.incoming_emails(@data['email']);
	email = emails.first.to_s;
	confirmation_link = email[email.index('https://'), email.index('">') - email.index('https://') - 1];
	@agent.get(confirmation_link);        
    end
    
end

include Account;
usersCount = ARGV[0].to_i;
usersCount.times {
    Account::createUser;
    Account::output;   
}
