require 'pg'

class DatabaseConnection
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV('DATABASE_URL'))
          elsif Sinatra::Base.test?
            PG.connect(dbname: 'persona_test')
          else
            PG.connect(dbname: 'persona')
          end
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
end
