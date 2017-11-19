require_relative("../db/sql_runner")
require_relative('ticket')
require_relative('film')
require_relative('screening')

class Customer

  attr_reader :id
  attr_accessor :name, :funds

  def initialize(options)
    @id = options['id'].to_i
    @name = options['name']
    @funds = options['funds'].to_i
  end

  def save()
    sql = "INSERT INTO customers
    (
      name, funds
    )
    VALUES
    (
      $1, $2
    )
    RETURNING *"
    values = [@name, @funds]
    @id = SqlRunner.run(sql,values)[0]['id'].to_i
  end

  def self.all()
    sql = "SELECT * FROM customers"
    customers = SqlRunner.run(sql)
    return customers.map {|customer| Customer.new(customer)}
  end


  def update
    sql = "UPDATE customers
    SET (name, funds) = ($1, $2)
    WHERE id = $3"
    values = [@name, @funds, @id]
    SqlRunner.run(sql,values)
  end

  def delete
    sql = "DELETE FROM customers WHERE id = $1"
    values =[@id]
    SqlRunner.run(sql,values)
  end

  def self.delete_all()
    sql = "DELETE FROM customers"
    SqlRunner.run(sql)
  end


  def self.find(id)
    sql = "SELECT * FROM customers WHERE id = $1"
    values = [id]
    result = SqlRunner.run(sql, values)
    return result.map{|find| Customer.new(find)}
  end


  def films
    sql = "SELECT films.*
    FROM films
    INNER JOIN tickets
    ON tickets.film_id = films.id
    WHERE tickets.customer_id = $1"
    values = [@id]
    result = SqlRunner.run(sql,values)
    return result.map {|film| Film.new(film)}
  end

  def buy_ticket(screening)
    screening.sell_ticket(self, screening)
    @funds -= screening.film.price
    self.update
  end

end
