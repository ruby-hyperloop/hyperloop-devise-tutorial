class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable unless RUBY_ENGINE == 'opal'

  # def self.current
  #   find(Hyperloop::Application.acting_user_id) if Hyperloop::Application.acting_user_id
  # end

end
