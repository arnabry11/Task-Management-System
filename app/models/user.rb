class User < ApplicationRecord
  include ApplicationHelper

  has_secure_password(validations: false) 

  has_many :tasks, foreign_key: "assign_task_to", dependent: :destroy
  has_many :notifications, foreign_key: "user_id"
  
  mount_uploader :avater, AvaterUploader
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
                      #/\A([a-zA-Z0-9]+)([.{1}])?([a-zA-Z0-9]+)@g(oogle)?mail([.])com\z/.freeze
  VALID_PHONE_REGEX=/\A[6-9][0-9]{9}\z/.freeze

  before_validation { self.name = name.to_s.titleize.strip }
  before_validation { self.email = email.to_s.downcase.strip }

  validates :name, length: { in: 3..50 }
  validates :email, format: { with: VALID_EMAIL_REGEX }
  validates :phone, length: {is: 10}, format: { with: VALID_PHONE_REGEX }
  # validate :valid_dob
  validates :password, length: { minimum: 5 }, allow_nil: true
  validates_presence_of :name, :email, :phone, :dob
  validates_uniqueness_of :email, :phone, case_sensitive: true

  scope :all_users_except_admin, -> { where(admin: false)}
  scope :all_hr, -> { where(hr: true) }
  scope :all_admin, -> { where(admin: true) }
  scope :all_employee, -> {where(admin: false, hr: false)}

  def digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def user_name
    self.name
  end

  def self.total_users
    self.count
  end

  def self.from_omniauth(auth)
    data = auth.info
    user = User.where(email: data["email"]).first
    user
  end
  
  def self.all_except(user)
    where.not(id: user)
  end

  def self.filter_by_role(param, current_user)
    if param == "" || !param
      if current_user.admin
        self.all.order("name ASC")
      elsif current_user.hr
        self.all_users_except_admin.order("name ASC") 
      end
    elsif param == "Admin"
      self.all_admin.order("name ASC") unless current_user.hr
    elsif param == "HR"
      self.all_hr.order("name ASC")
    else
      self.all_employee.order("name ASC")
    end
  end

  private

  # def valid_dob
  #   if dob >= Date.today
  #     errors.add(:dob, "is invalid")
  #   elsif dob > 18.years.ago.to_date
  #     errors.add("DOB should be before ", 18.years.ago.to_date)
  #   end
  # end
end
