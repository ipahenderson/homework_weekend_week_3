require_relative("../db/sql_runner")
require_relative('customer')
require_relative('film')
require_relative('screening')

class Ticket

  attr_reader :id
  attr_accessor :customer_id, :film_id, :screening_id

  def initialize(options)
    @id = options['id'].to_i
    @customer_id = options['customer_id'].to_i
    @film_id = options['film_id'].to_i
    @screening_id = options['screening_id'].to_i
  end

  def save()
    sql = "INSERT INTO tickets
    (
      customer_id, film_id, screening_id
    )
    VALUES
    (
      $1, $2, $3
    )
    RETURNING *"
    values = [@customer_id, @film_id, @screening_id]
    @id = SqlRunner.run(sql,values)[0]['id'].to_i
  end

  def self.all()
    sql = "SELECT * FROM tickets"
    tickets = SqlRunner.run(sql)
    return tickets.map {|ticket| Tickets.new(ticket)}
  end


  def update
    sql = "UPDATE tickets
    SET (customer_id, film_id, screening_id) = ($1, $2, $3)
    WHERE id = $4"
    values = [@customer_id, @film_id, @screening_id, @id]
    SqlRunner.run(sql,values)
  end

  def delete
    sql = "DELETE FROM tickets WHERE id = $1"
    values =[@id]
    SqlRunner.run(sql,values)
  end

  def self.delete_all()
    sql = "DELETE FROM tickets"
    SqlRunner.run(sql)
  end


  def self.find(id)
    sql = "SELECT * FROM tickets WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values)
    return result.map{|find| Ticket.new(find)}
  end


  def films
    sql = "SELECT *
          FROM films
          WHERE id = $1"
    values = [@films_id]
    result = SqlRunner.run(sql,values)[0]
    return Film.new(result)
  end

  def customers
    sql = "SELECT *
          FROM customers
          WHERE id = $1"
    values = [@customer_id]
    result = SqlRunner.run(sql,values)[0]
    return Customer.new(result)
  end


end
