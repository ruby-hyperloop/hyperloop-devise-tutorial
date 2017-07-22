# Devise with Hyperloop Tutorial

This tutorial will demonstrate how to use the popular [Devise Gem](https://github.com/plataformatec/devise) with Hyperloop. In this tutorial we will be using the standard Devise user session ERB views for all Devise related activity (creating user, changing password, etc), and demonstrating how Hyperloop co-exists with Devise.

The goal of this tutorial is to demonstrate the interactivity between Hyperloop and Devise, so we will go quickly through the setup of Hyperloop and Devise. If these technologies are new to you then this is not the ideal tutorial to start with. Please be sure to see the [Hyperloop with Rails titorials](http://ruby-hyperloop.io/tutorials/hyperlooprails/) and the [Devise Gem](https://github.com/plataformatec/devise) first.

## Setup

If you already have Devise and Hyperloop setup you can skip this section and go directly to [Using Devise with Hyperloop](#using-devise-with-hyperloop)

### Creating a new Rails app

Assuming you have Ruby and Rails installed, from the command line type:

`rails new devise_hyperloop`
`cd devise_hyperloop`
`bundel install`

We are going to need a User model, so lets create a simple one now:

`rails g model User first_name:string last_name:string`

The migrate the database:

`rails db:migrate`

### Installing Hyperloop and creating a simple Component

Firstly add the master Hyperloop gem to your `Gemfile`

```ruby
# Gemfile
gem 'hyperloop'
```

Next run bundle:

`bundle install`

Then run the Hyperloop generator:

`rails g hyperloop:install`

To create a basic Component, run this command:

`rails g hyper:component Helloworld`

And finally create a route in `routes.rb` which points to the Helloworld Component we have just created.

>Note that this shortcut replaces the need for a Rails controller and view. There is an automagical `hyperloop` controller which will load the component specified. If you prefer to not take this shortcut you can create a controller and view which will load your Helloworld Component instead. See the Hyperloop website for details on how to do this.

For this tutorial we will take the shortcut:

```ruby
# routes.rb
root 'hyperloop#helloworld'
```

If you start your rails server and navigate to `localhost:3000` you should be rewarded with `Helloworld` being displayed in your browser. Admittedly this is not very exciting, but it does prove that Hyperloop is correctly installed.

As a final step, so that Hyperloop can see the User model, we will move it (and applciation_record.rb for Rails 5.x) to the `hyperloop/models` folder.

`mv app/models/user.rb app/hyperloop/models/`
`mv app/models/application_record.rb app/hyperloop/models/`

### Installing Devise

Next we will install Devise. In your `Gemfile` add:

```ruby
# Gemfile
gem 'devise'
```

Then bundle:

`bundle install`

Then run the Devise generator:

`rails generate devise:install`

As this tutorial is not about Devise but rather its connection to Hyperloop, we will do the minimal Devise setup required. Please see the Devise website for more information on setting up Devise thoroughly.

Devise needs to augment our User model so we will run a generator for that:

`rails g devise User`

Then migrate again:

`rails db:migrate`

At this point Devise should be setup and working. Lets test that by starting your Rails server and navigating to:

`http://localhost:3000/users/sign_up`

You should see a very basic looking signup page! Now we know that Devise is setup and working.

As a final setp, we need to tell Rails to protect all our controllers with Devise. Add the following line to your `application_controller.rb`

```ruby
# application_controller.rb
before_action :authenticate_user!
```

At this stage we have Hyperloop and Devise installed so now we will think about how to connect them.

## Using Devise with Hyperloop

To summarise the steps above:

+ We have created a new Rails app with a User model
+ Hyperloop is installed and we have a Helloworld component
+ We have moved out User model to the `hyperloop/models` folder so that is accessible to both our client and server code
+ Devise is installed and we have run the generator for Devise to add additional fields to our User model
+ We have protected all our Rail controllers by adding a `before_action` to our ApplicationController

### Keeping Devise code on the server

There is one last configuration step we need to preform. Devise has added code to our User model which we want on the server but not on the client. To achieve this we simply wrap the code in a `unless RUBY_ENGINE == 'opal'` test.

Add the test to your User model like this:

```ruby
# app/hyperloop/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable unless RUBY_ENGINE == 'opal'
end
```

### Check that it is all working

If you restart your Rails server and navigate to `http://localhost:3000/` you should be redirected to a Sign up page.

Complete the signup and you should be redirected to Hyperloop route which renders our Helloworld component. You should see this in your browser:

```
Welcome! You have signed up successfully.

Helloworld
```

### Accessing `current_user` in Hyperloop

Hyperloop looks for a method called `acting_user` which is typically defined in the ApplicationController. Devise adds a `current_user` helper which is accessible in your controllers and views.

To get Hyperloop to see the Devise `current_user` we simply alias the method

```ruby
  def acting_user
    current_user
  end
```



------------------

So you were asking about how to integrate devise and get the current user on the client right?


also I'm sorry about this, but while I showed you what I think is the "right" way to do it... there is an easier way.

inside of your hyperloop app you can say

User.find( Hyperloop::Application.acting_user_id )


, and as long as you have aliased acting_user to current_user in your ApplicationController, you will have the current acting_user id on the client anytime.

I had forgotten that acting_user_id was available... but the way I described you will have the id right in the URL as well.

yes better to place to start... sorry about that

You can also keep you code tidy by doing the following as well:

class User < ...
  def self.current
    find(Hyperloop::Application.acting_user_id) if Hyperloop::Application.acting_user_id
  end
end

# now you can say User.current on the client

-------------

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.


  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views
