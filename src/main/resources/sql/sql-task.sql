-- 1. Вывести к каждому самолету класс обслуживания и количество мест этого класса

SELECT aircrafts_data.aircraft_code, seats.fare_conditions, COUNT(seats.seat_no) AS num_seats
FROM aircrafts_data
         JOIN seats  ON seats.aircraft_code = aircrafts_data.aircraft_code
GROUP BY aircrafts_data.aircraft_code, seats.fare_conditions;

-- 2. Найти 3 самых вместительных самолета (модель + кол-во мест)

SELECT aircrafts.model, COUNT(seats.seat_no) AS num_seats
FROM aircrafts
    JOIN seats  ON seats.aircraft_code = aircrafts.aircraft_code
GROUP BY aircrafts.model
ORDER BY num_seats DESC
LIMIT 3;

-- 3. Вывести код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам

SELECT aircrafts.aircraft_code, aircrafts.model AS model, seats.seat_no, seats.fare_conditions
FROM aircrafts
    JOIN aircrafts_data  ON aircrafts.aircraft_code = aircrafts_data.aircraft_code
    JOIN seats  ON seats.aircraft_code = aircrafts.aircraft_code
WHERE aircrafts.model LIKE '%Аэробус A321-200%' AND seats.fare_conditions != 'Economy'
ORDER BY seats.seat_no;

-- 4. Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)

SELECT airports.airport_code, airports.airport_name, airports.city
FROM airports
WHERE airports.city IN (
    SELECT airports.city
    FROM airports
    GROUP BY airports.city
    HAVING COUNT(*) > 1
)
ORDER BY airports.city;

-- 5. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация

SELECT flights.flight_no, flights.scheduled_departure, boarding_passes.seat_no
FROM flights
    JOIN ticket_flights ON ticket_flights.flight_id = flights.flight_id
    LEFT JOIN boarding_passes ON boarding_passes.flight_id = flights.flight_id
                                     AND boarding_passes.boarding_no = 1
WHERE flights.departure_airport = 'SVX' AND flights.arrival_airport = 'SVO'
AND flights.status = 'Scheduled' AND boarding_passes.boarding_no IS NULL
ORDER BY flights.scheduled_departure
LIMIT 1;

-- For better reading it can write this way:

SELECT f.flight_no, f.scheduled_departure, bp.seat_no
FROM flights f
    JOIN ticket_flights tf ON tf.flight_id = f.flight_id
    LEFT JOIN boarding_passes bp ON bp.flight_id = f.flight_id
                                        AND bp.boarding_no = 1
WHERE f.departure_airport = 'SVX' AND f.arrival_airport = 'SVO'
AND f.status = 'Scheduled' AND bp.boarding_no IS NULL
ORDER BY f.scheduled_departure
LIMIT 1;

-- Also all example above could write with aliases.


-- 6. Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)

SELECT MIN(amount) AS cheapest_ticket_price, MAX(amount) AS most_expensive_ticket_price
FROM ticket_flights;

-- 7. Написать DDL таблицы Customers , должны быть поля id , firstName, LastName, email , phone.
-- Добавить ограничения на поля ( constraints)

CREATE TABLE Customers (
  id SERIAL PRIMARY KEY,
  firstName VARCHAR(50) NOT NULL,
  lastName VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20) NOT NULL,
  CONSTRAINT valid_phone CHECK (phone ~ '^\+?[0-9]{1,3}-?[0-9]{1,14}$')
);

-- 8. Написать DDL таблицы Orders , должен быть id, customerId,
-- quantity. Должен быть внешний ключ на таблицу customers + ограничения

CREATE TABLE Orders (
  id SERIAL PRIMARY KEY,
  customerId INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  CONSTRAINT fk_customerId FOREIGN KEY (customerId) REFERENCES Customers (id),
  CONSTRAINT positive_quantity CHECK (quantity > 0)
);

-- 9. Написать 5 insert в эти таблицы

-- Insert into Customers:

INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('Alexey', 'Zabalotcki', 'alexeyzabalotckibusiness@gmail.com', '111-2345');

-- Insert into Customers:

INSERT INTO Customers (firstName, lastName, email, phone)
VALUES ('Alexey', 'Ivanou', 'ivanou@gmail.com', '123-1234');

-- Insert into Orders:

INSERT INTO Orders (customerId, quantity)
VALUES (4, 5);

-- Insert into Orders:

INSERT INTO Orders (customerId, quantity)
VALUES (5, 10);

-- Insert into Orders:

INSERT INTO Orders (customerId, quantity)
VALUES (4, 3);

-- 10. удалить таблицы

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

-- 11. Найти все рейсы, вылетающие из города Москва и прилетающие в город Санкт-Петербург
-- и отсортировать их по времени отправления.

SELECT f.flight_no, f.scheduled_departure, f.scheduled_arrival,
a.airport_name AS departure_airport, arr.airport_name AS arrival_airport
FROM Flights f
JOIN Airports a ON f.departure_airport = a.airport_code
JOIN Airports AS arr ON f.arrival_airport = arr.airport_code
WHERE a.city = 'Москва' AND arr.city = 'Санкт-Петербург'
ORDER BY f.scheduled_departure ASC;
