# Devise with Hypetloop Tutorial

New rails app
`rails new devise_tutorial`
`bundel install`

Install Hyperloop
`gem 'hyperloop'`
`bundle install`
`rails g hyperloop:install`
`rails g hyper:component Helloworld`
//= require jquery
//= require jquery_ujs

Create a User model
`rails g model User first_name:string last_name:string`
`rails db:migrate`

Install devise
`gem 'devise'`
`bundle install`
`rails generate devise:install`

Setup Devise

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

Create the fields Devise needs on the User model
`rails generate devise User`

Migrate
`rails db:migrate`
