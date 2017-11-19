require_relative("../db/sql_runner")
require_relative('customer')
require_relative('film')
require_relative('ticket')

class Screening

  attr_reader :id, :film_id, :start_time
  attr_accessor :empty_seats

  def initialize(options)
    @id = options['id'].to_i
    @film_id = options['film_id'].to_i
    @start_time = options['start_time']
    @empty_seats = options['empty_seats'].to_i
  end

  def save()
    sql = "INSERT INTO screenings
    (
      film_id, start_time, empty_seats
    )
    VALUES
    (
      $1, $2, $3
    )
    RETURNING *"
    values = [@film_id, @start_time, @empty_seats]
    @id = SqlRunner.run(sql,values)[0]['id'].to_i
  end

  def self.all()
    sql = "SELECT * FROM screenings"
    screenings = SqlRunner.run(sql)
    return screenings.map {|screening| Screening.new(screening)}
  end


  def update
    sql = "UPDATE screenings
    SET (film_id, start_time) = ($1, $2, $3)
    WHERE id = $4"
    values = [@film_id, @start_time, @empty_seats, @id]
    SqlRunner.run(sql,values)
  end

  def delete
    sql = "DELETE FROM screenings WHERE id = $1"
    values =[@id]
    SqlRunner.run(sql,values)
  end

  def self.delete_all()
    sql = "DELETE FROM screenings"
    SqlRunner.run(sql)
  end


  def self.find(id)
    sql = "SELECT * FROM screenings WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values)
    return result.map{|find| Screening.new(find)}
  end


  def film
    sql = "SELECT *
          FROM films
          WHERE id = $1"
    values = [@film_id]
    result = SqlRunner.run(sql,values)[0]
    return Film.new(result)
  end

  def seats_free?
    @empty_seats >= 1
  end

  def sell_ticket(customer, screening)
    if screening.seats_free? == false
      return "No seats left"
    else
    ticket = Ticket.new(
      {
        'customer_id' => customer.id,
        'film_id' => screening.film.id,
        'screening_id' => screening.id
        }
      )
    ticket.save
    end
  end

  def self.most_popular
    sql = "
     SELECT screening_id, COUNT(screening_id) FROM tickets
     GROUP BY screening_id
     ORDER BY count DESC
     "
    result = SqlRunner.run(sql)[0]
    most_popular = result['screening_id'].to_i
    Screening.find(most_popular)
  end

end
