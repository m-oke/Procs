# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :email,
  :presence => true,
  :email_format => { :message => 'の形式が正しくありません' },
  :confirmation => true,
  :uniqueness => true

  validates :email_confirmation,
  :presence => true,
  if: Proc.new {|obj| obj.new_record? || !obj.email_confirmation.blank?}

  validates :name, :length => {:maximum => 255}

  validates :nickname,
  :presence => true,
  :length => {:minimum => 1, :maximum => 255},
  # アスキー文字33~126対応
  :format => {:with => /\A[!-~]{1,255}\z/, :message => 'は適切なフォーマットではありません' }

  validates :password,
  :presence => true,
  :length => {:minimum => 1, :maximum => 255},
  :format => {:with => /\A[!-~]{8,255}\z/, :message => 'は適切なフォーマットではありません' },
  if: Proc.new {|obj| obj.new_record? || !obj.email_confirmation.blank?}


  has_many :user_lessons, :foreign_key => :user_id
  has_many :lessons, :through => :user_lessons

  has_many :answers, :foreign_key => :student_id
  has_many :questions, :through => :answers
  has_many :questions, :foreign_key => :author

  ROLES = %i[root admin teacher student]

  def roles=(roles)
    roles = [*roles].map { |r| r.to_sym }
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
  end

  def roles
    ROLES.reject do |r|
    ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
    end
  end

  def has_role?(role)
    roles.include?(role)
  end

  # ユーザが該当するrolesに所属するかどうか
  # @param [Array] role roleを記述した配列
  # @return [Boolean] 結果
  def has_roles?(role)
    role.each do |r|
      if !roles.include?(r)
        return false
      end
    end
    return true
  end



  rails_admin do
    weight 1

    create do
      field :student_number do
        help "学籍番号など，#{help}"
      end
      field :name do
        help "本名など，#{help}"
      end
      field :nickname do
        help "ニックネームなど他のユーザに表示される，#{help}"
        required true
      end
      field :roles do
        help "ユーザの権限，#{help}"
        required true
        partial 'roles_form'
      end
      field :email do
        required true
        help "ログインに使用，#{help}"
      end
      field :email_confirmation do
        required true
      end
      field :password do
        required true
      end
      field :password_confirmation do
        required true
      end
    end

    edit do
      field :student_number do
        visible do
          bindings[:view]._current_user.has_role?(:root)
        end
        help "学籍番号など，#{help}"
      end
      field :name do
        visible do
          bindings[:view]._current_user.has_role?(:root)
        end

        help "本名など，#{help}"
      end
      field :nickname do
        visible do
          bindings[:view]._current_user.has_role?(:root)
        end

        help "ニックネームなど他のユーザに表示される，#{help}"
        required true
      end
      field :roles do
        help "ユーザの権限, #{help}"
        required true
        partial 'roles_form'
      end
      field :email do
        visible do
          bindings[:view]._current_user.has_role?(:root)
        end

        required true
        help "ログインに使用，#{help}"
      end
      field :email_confirmation do
        visible do
          bindings[:view]._current_user.has_role?(:root)
        end
        required true
      end

      field :password do
        visible do
          bindings[:view]._current_user.has_role?(:root)
        end

      end
      field :password_confirmation do
        visible do
          bindings[:view]._current_user.has_role?(:root)
        end

      end
    end

    list do
      field :id
      field :student_number
      field :name
      field :nickname
      field :roles do
        formatted_value do
          val = ""
          value.to_a.each_with_index do |role, i|
            val += "#{role.to_s}"
            unless (i + 1) == value.size
              val += ", "
            end
          end
          val
        end
      end
      field :email
      field :lessons
      field :reset_password_sent_at
      field :remember_created_at
      field :sign_in_count
      field :current_sign_in_at
      field :last_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_ip
      field :created_at
      field :updated_at
    end

    show do
      field :student_number
      field :name
      field :nickname
      field :roles do
        formatted_value do
          val = ""
          value.to_a.each_with_index do |role, i|
            val += "#{role.to_s}"
            unless (i + 1) == value.size
              val += ", "
            end
          end
          val
        end
      end
      field :email
      field :lessons
      field :sign_in_count
      field :current_sign_in_at
      field :last_sign_in_at
      field :current_sign_in_ip
      field :last_sign_in_ip
      field :created_at
      field :updated_at
    end



  end
end
