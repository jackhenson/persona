require 'pg'
require_relative 'business'

class DatabaseConnection
  def initialize(logger = nil)
    @db = if Sinatra::Base.production?
            PG.connect(ENV('DATABASE_URL'))
          elsif Sinatra::Base.test?
            PG.connect(dbname: 'persona_test')
          else
            PG.connect(dbname: 'persona')
          end
    @logger = logger
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}" unless ENV['RACK_ENV'] == 'test'
    @db.exec_params(statement, params)
  end

  def delete_all_data
    @db.exec 'DELETE FROM profiles;'
    @db.exec 'ALTER SEQUENCE profiles_id_seq RESTART WITH 1;'
    @db.exec 'DELETE FROM users;'
    @db.exec 'ALTER SEQUENCE users_id_seq RESTART WITH 1;'
    @db.exec 'DELETE FROM businesses;'
    @db.exec 'ALTER SEQUENCE businesses_id_seq RESTART WITH 1;'
  end

  def create_new_biz(uuid, biz_name)
    sql = 'INSERT INTO businesses (uuid, name) VALUES ($1, $2);'
    query(sql, uuid, biz_name)
  end

  def create_new_user(uuid, user_params)
    biz_id = fetch_biz_id(uuid)
    sql = 'INSERT INTO users (name, age, bio, love_phrase, hate_phrase, biz_id)
            VALUES ($1, $2, $3, $4, $5, $6)'
    query(sql, user_params[:name], user_params[:age], user_params[:bio],
          user_params[:love], user_params[:hate], biz_id)
  end

  def fetch_biz_id(uuid)
    sql = 'SELECT id FROM businesses WHERE uuid = $1 LIMIT 1'
    result = query(sql, uuid)
    result.values.flatten.first.to_i
  end

  def valid_uuid?(uuid)
    uuid.match?(/\A[0-9a-zA-Z]{8}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{4}-[0-9a-zA-Z]{12}\z/)
  end

  def valid_business?(uuid)
    valid_uuid?(uuid) && fetch_biz_id(uuid) > 0 ? true : false
  end

  def load_business(uuid)
    sql = <<~SQL
      SELECT b.id      AS biz_id,
             b.uuid    AS biz_uuid,
             b.name    AS biz_name,
             u.id      AS user_id,
             u.name    AS user_name,
             u.age,
             u.bio,
             u.love_phrase,
             u.hate_phrase,
             p.id      AS profile_id,
             p.need,
             p.motivation,
             p.challenge
        FROM businesses b
        LEFT JOIN users u
          ON b.id = u.biz_id
        LEFT JOIN profiles p
          ON u.id = p.user_id
       WHERE b.uuid = $1
       ORDER BY u.id;
    SQL

    result = query(sql, uuid)
    tuple_to_business(result)
  end
end

def tuple_to_business(result)
  Business.new(
    result.field_values('biz_id').first.to_i,
    result.field_values('biz_uuid').first,
    result.field_values('biz_name').first,
    result.field_values('user_id').first.nil? ? [] : tuples_to_users(result)
  )
end

def tuples_to_users(result)
  result.each_with_object([]) do |user_tuple, arr|
    arr << User.new(
      user_tuple['user_id'].to_i,
      user_tuple['user_name'],
      user_tuple['age'],
      user_tuple['bio'],
      user_tuple['love_phrase'],
      user_tuple['hate_phrase'],
      tuple_to_profile(user_tuple)
    )
  end
end

def tuple_to_profile(user_tuple)
  Profile.new(
    user_tuple['profile_id'].to_i,
    user_tuple['need'],
    user_tuple['motivation'],
    user_tuple['challenge']
  )
end
