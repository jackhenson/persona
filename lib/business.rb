class Business
  attr_reader :id, :uuid, :name, :users

  def initialize(id, uuid, name, users)
    @id = id
    @uuid = uuid
    @name = name
    @users = users
  end
end

class User
  attr_reader :id, :name, :age, :bio, :love_phrase, :hate_phrase, :profile

  def initialize(id, name, age, bio, love_phrase, hate_phrase, profile)
    @id = id
    @name = name
    @age = age
    @bio = bio
    @love_phrase = love_phrase
    @hate_phrase = hate_phrase
    @profile = profile
  end
end

class Profile
  attr_reader :id, :need, :motivation, :challenge

  def initialize(id, need, motivation, challenge)
    @id = id
    @need = need
    @motivation = motivation
    @challenge = challenge
  end
end
