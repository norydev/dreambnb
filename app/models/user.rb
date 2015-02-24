class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [ :facebook ]

  has_many :flats
  has_many :bookings

  has_attached_file :avatar,
    styles: { big: "600x600#", medium: "300x300#", thumb: "100x100#" },
    :default_url => "default_user_picture.svg"

  validates_attachment_content_type :avatar,
    content_type: /\Aimage\/.*\z/

  def self.find_for_facebook_oauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.picture = "#{auth.info.image}?type=large"
      user.token = auth.credentials.token
      user.token_expiry = Time.at(auth.credentials.expires_at)
    end
  end

  def image
    if avatar.file? || picture.nil?
      return avatar.url(:big)
    else
      return picture
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

end
