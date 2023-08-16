class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_one :member, :dependent => :destroy
  has_and_belongs_to_many :tenants
  has_many :user_projects
  has_many :projects, through: :user_projects

  def is_admin?
      is_admin
  end

  # ------------------------------------------------------------------------
  # ------------------------------------------------------------------------

  # ------------------------------------------------------------------------
  # save_and_invite_member -- saves the new user record thus inviting member
      # via devise
      # if password missing; gens a password
      # ensures email exists and that email is unique and not already in system
  # imported directly from milia : lib/milia/invite_member.rb
  # ------------------------------------------------------------------------
  def save_and_invite_member
      status = nil
      if (self.email.blank?)
          self.errors.add(:email, :blank)
      elsif User.where([ "lower(email) = ?", self.email.downcase ]).present?
          self.errors.add(:email, :taken)
      else
          if self.password.blank?
              self.password = "password"
              self.password_confirmation = self.password
          else
              # if a password is being supplied, then ok to skip
              # setting up a password upon confirm
              self.skip_confirm_change_password = true #if ::Milia.use_invite_member
          end
          status = self.save && self.errors.empty?
      end
      return status
  end
     
end
