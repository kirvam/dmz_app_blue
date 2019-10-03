create table if not exists movies (
  movie_id INT AUTO_INCREMENT PRIMARY KEY, 
  title VARCHAR(50),
  rating INT,
  phase INT,
  year_pub CHAR(4),
  description TEXT 
); 
