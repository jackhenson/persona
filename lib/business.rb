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
  attr_reader :id, :name, :age, :bio, :love_phrase, :hate_phrase, :need, :motivation, :challenge

  def initialize(id, name, age, bio, love_phrase, hate_phrase, _need, _motivation, challenge)
    @id = id
    @name = name
    @age = age
    @bio = bio
    @love_phrase = love_phrase
    @hate_phrase = hate_phrase
    @need = need
    @motivation = motivation
    @challenge = challenge
  end
end
