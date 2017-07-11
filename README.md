# Devise with Hypetloop Tutorial

New rails app
`rails new devise_tutorial`
`bundel install`

Create a User model
`rails g model User first_name:string last_name:string email:string`
`rake db:migrate`

Install devise
`gem 'devise'`
`bundle install`
`rails generate devise:install`
