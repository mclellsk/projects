CREATE SCHEMA webapp;

CREATE TABLE webapp.users
(
	email VARCHAR(256) NOT NULL,
	pw VARCHAR(256) NOT NULL,
	salt VARCHAR(256) NOT NULL,
	vcode VARCHAR(256) NOT NULL,
	active BIT DEFAULT 0,
	PRIMARY KEY (email)
);

DELIMITER $$
CREATE PROCEDURE webapp.DoesExist(IN email VARCHAR(256), OUT result INT)
BEGIN
	SET result = -1;
	IF (email != '') THEN
		SELECT COUNT(*) INTO result FROM webapp.users AS u WHERE u.email = email; 
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE webapp.Register(IN email VARCHAR(256), IN pw VARCHAR(256), OUT result INT, OUT vcode VARCHAR(256))
BEGIN
	SET vcode = '';
	SET result = -1;
	IF (email != '' AND pw != '') THEN
		SET @exist = 0;
		CALL webapp.DoesExist(email, @exist);
		IF (@exist <= 0) THEN
			SET @salt = SHA2(RAND(),0);
			SET @hashpw = SHA2(concat(pw, @salt),0);
			SET vcode = SHA2(RAND(),0);
			INSERT INTO webapp.users (email, pw, salt, vcode) VALUES (email, @hashpw, @salt, vcode);
			SET result = 1;
		END IF;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE webapp.Activate(IN email VARCHAR(256), IN vcode VARCHAR(256), OUT result INT)
BEGIN
	SET result = -1;
	IF (email != '') THEN
		SELECT COUNT(*) INTO result FROM webapp.users AS u WHERE u.email = email AND u.vcode = vcode;
		IF (result > 0) THEN
			UPDATE webapp.users AS u SET u.active = 1 WHERE u.email = email;
		END IF;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE webapp.Login(IN email VARCHAR(256), IN pw VARCHAR(256), OUT result INT)
BEGIN
	SET result = -1;
	IF (email != '' AND pw != '') THEN
		SET @exist = -1;
		CALL webapp.DoesExist(email, @exist);
		IF (@exist > 0) THEN
			SET @salt = '';
			SELECT u.salt INTO @salt FROM webapp.users AS u WHERE u.email = email;
			SET @hashpw = SHA2(concat(pw, @salt),0);
			SELECT COUNT(*) INTO result FROM webapp.users AS u WHERE u.email = email AND u.pw = @hashpw AND u.active = 1;
            IF (result < 1) THEN
				SET result = -2;
            END IF;
		END IF;
	END IF;
END $$
DELIMITER ;