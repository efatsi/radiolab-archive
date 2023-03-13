class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_episodes

  before_validation :generate_token, on: :create

  validates :token, presence: true

  private

  def generate_token
    begin
      self.token = rand(10000000..99999999)
    end while User.exists?(token: self.token)
  end
end
