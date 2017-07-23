# Devise with Hyperloop Tutorial

This tutorial will demonstrate how to use the popular [Devise Gem](https://github.com/plataformatec/devise) with Hyperloop. In this tutorial, we will be using the standard Devise user session ERB views for all Devise related activity (creating the user, changing the password, etc), and demonstrating how Hyperloop co-exists with Devise.

The goal of this tutorial is to demonstrate the interactivity between Hyperloop and Devise, so we will go quickly through the setup of Hyperloop and Devise. If these technologies are new to you then this is not the ideal tutorial to start with. Please be sure to see the [Hyperloop with Rails titorials](http://ruby-hyperloop.io/tutorials/hyperlooprails/) and the [Devise Gem](https://github.com/plataformatec/devise) first.

## Setup

If you already have Devise and Hyperloop setup you can skip this section and go directly to [Using Devise with Hyperloop](#using-devise-with-hyperloop)

### Creating a new Rails app

Assuming you have Ruby and Rails installed, from the command line type:

`rails new devise_hyperloop`
`cd devise_hyperloop`
`bundel install`

We are going to need a User model, so let's create a simple one now:

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

Next, create a route in `routes.rb` which points to the Helloworld Component we have just created.

>Note that this shortcut replaces the need for a Rails controller and view. There is an automagical `hyperloop` controller which will load the component specified. If you prefer to not take this shortcut you can create a controller and view which will load your Helloworld Component instead. See the Hyperloop website for details on how to do this.

For this tutorial we will take the shortcut:

```ruby
# routes.rb
root 'hyperloop#helloworld'
```

Next, we should check that out transport is configured properly. This tutorial uses ActionCable.

>See [http://ruby-hyperloop.io/docs/models/configuring-transport/](http://ruby-hyperloop.io/docs/models/configuring-transport/) for other transport options.

In `config/initializers/hyperloop.rb` ensure that a valid transport is configured:

```ruby
# config/initializers/hyperloop.rb
Hyperloop.configuration do |config|
  config.transport = :action_cable
end
```

To access our User Model on the client, Hyperloop needs to see it, so we will move it (and applciation_record.rb for Rails 5.x) to the `hyperloop/models` folder.

`mv app/models/user.rb app/hyperloop/models/`
`mv app/models/application_record.rb app/hyperloop/models/`

If you start your rails server and navigate to `localhost:3000` you should be rewarded with `Helloworld` being displayed in your browser. Admittedly this is not very exciting, but it does prove that Hyperloop is correctly installed.

### Installing Devise

Next, we will install Devise. In your `Gemfile` add:

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

At this point, Devise should be setup and working. Let's test that by starting your Rails server and navigating to:

`http://localhost:3000/users/sign_up`

You should see a very basic looking signup page! Now we know that Devise is setup and working.

As a final step, we need to tell Rails to protect all our controllers with Devise. Add the following line to your `application_controller.rb`

```ruby
# application_controller.rb
before_action :authenticate_user!
```

At this stage, we have Hyperloop and Devise installed so now we will think about how to connect them.

## Using Devise with Hyperloop

To summarize the steps above:

+ We have created a new Rails app with a User model
+ Hyperloop is installed and we have a Helloworld component
+ Our Hyperloop transport is configured so data can move from the server to the client
+ We have moved out User model to the `hyperloop/models` folder so that is accessible to both our client and server code
+ Devise is installed and we have run the generator for Devise to add additional fields to our User model
+ We have protected all our Rail controllers by adding a `before_action` to our ApplicationController

### Keeping Devise code on the server

There is one last configuration step we need to perform. Devise has added code to our User model which we want on the server but not on the client. To achieve this we simply wrap the code in an `unless RUBY_ENGINE == 'opal'` test.

Add the test to your User model like this:

```ruby
# app/hyperloop/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable unless RUBY_ENGINE == 'opal'
end
```

### Check that it is all working

If you restart your Rails server and navigate to `http://localhost:3000/` you should be redirected to a Signup page.

Complete the signup and you should be redirected to Hyperloop route which renders our Helloworld component. You should see this in your browser:

```
Welcome! You have signed up successfully.

Helloworld
```

### Linking Hyperloop and Devise

Devise makes it really easy to access the currently logged in User through a `current_user` helper which is available in your Rails controllers and views servers-side.

To get this inofrmation client-side, we need to tell Hyperloop (server side) we need to link Hyperloop's `acting_user` with Devise's `current_user` by creating an `acting_user` method in our `ApplicationController` which aliases `current_user`:

```ruby
# app/controllers/application_controller.rb
def acting_user
  current_user
end
```

Hyperloop will then call `ApplicationController::acting_user`, and set `Hyperloop::Application.acting_user_id` to the ID of `current_user`.

`Hyperloop::Application.acting_user_id` will then be available to your server and client-side code.

> Note: Today there is no easy way to reset this once it is set. This functionality is underway and this tutorial will be updated when it is available. However, to accomplish this today you would have to have the sign-in controller operation, dispatch to the the session channel, and then have the client listen for this dispatch and reset the page.

### Accessing the current_user on the client

Let's update our `Helloworld` Component so that it renders the current users's email.

To keep the concept of `Hyperloop::Application.acting_user_id` out of our client-side code, we will add a class method to `User` which will find and return the acting_user if one exists and an empty User object is one does not exist:

```ruby
# app/hyperloop/models/user.rb
def self.current
  Hyperloop::Application.acting_user_id ? find(Hyperloop::Application.acting_user_id) : User.new
end
```

Now to access out current_user we simply use `User.current`, so in the Helloworld Component

```ruby
# app/hyperloop/components/helloworld.rb
DIV do
  H1 {"Helloworld - #{User.current.email}"}
end
```
