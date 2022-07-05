CREATE DATABASE unicon;

CREATE TABLE users (
	id SERIAL NOT NULL PRIMARY KEY,
	name CHARACTER VARYING(32) NOT NULL
);

CREATE TABLE permissions (
	id SERIAL NOT NULL PRIMARY KEY,
	user_id INT NOT NULL REFERENCES users(id),
	action SMALLINT NOT NULL
);

-- permission.action = {
	-- 10 = CREATE_DOCUMENT
	-- 20 = CONTROL_DOCUMENT
	-- 30 = REPORT_TASK
--}

CREATE TABLE documents (
	id SERIAL NOT NULL PRIMARY KEY,
	name CHARACTER VARYING(64) NOT NULL,
	status SMALLINT DEFAULT 1,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL REFERENCES users(id) -- document owner
);
-- documents.status = { 0 = SOFT_DELETED, 1 = OPEN_OR_PENDING, 2 = EXECUTED_OR_CLOSED }

CREATE TABLE tasks (
	id SERIAL NOT NULL PRIMARY KEY,
	status SMALLINT DEFAULT 1,
	summary CHARACTER VARYING(128) NOT NULL,
	expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	document_id INT NOT NULL REFERENCES documents(id),
	user_id INT NOT NULL REFERENCES users(id) -- task main controller
);
-- tasks.status = { 0 = SOFT_DELETED, 1 = OPEN_OR_PENDING, 2 = EXECUTED_OR_CLOSED }

CREATE TABLE executors (
	id SERIAL NOT NULL PRIMARY KEY,
	status SMALLINT DEFAULT 1,
	report CHARACTER VARYING(256) NULL,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	user_id INT NOT NULL REFERENCES users(id),
	task_id INT NOT NULL REFERENCES tasks(id)
);
-- executors.status = { 0 = REJECTED, 1 = OPEN, 2 = PENDING, 3 = RESOLVED }

---------------------------------------
CREATE OR REPLACE FUNCTION set_report()  RETURNS TRIGGER LANGUAGE PLPGSQL
AS $$
BEGIN
	IF OLD.status = 1 AND NEW.report IS NOT NULL THEN
		NEW.status = 2;
	END IF;
	RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER set_report_tg BEFORE UPDATE ON executors
FOR EACH ROW EXECUTE PROCEDURE set_report();
---------------------------------------
CREATE OR REPLACE FUNCTION set_task_auto_status()  RETURNS TRIGGER LANGUAGE PLPGSQL
AS $$
BEGIN
	IF NEW.status = 3 AND (
		SELECT NOT EXISTS (
			SELECT * FROM executors WHERE task_id = NEW.task_id and status <> 3
		)
	) THEN
		UPDATE tasks set status = 2 WHERE id = NEW.task_id;
	END IF;
	RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER set_task_auto_status_tg AFTER UPDATE ON executors
FOR EACH ROW EXECUTE PROCEDURE set_task_auto_status();
---------------------------------------
CREATE OR REPLACE FUNCTION set_doc_auto_status()  RETURNS TRIGGER LANGUAGE PLPGSQL
AS $$
DECLARE doc_id integer;
BEGIN
	SELECT document_id FROM tasks INTO doc_id WHERE id = NEW.id;
	IF (
		SELECT NOT EXISTS(
			SELECT * FROM tasks WHERE status <> 2 AND document_id = doc_id
		)
	) THEN
		UPDATE documents SET status = 2 WHERE id = doc_id;
	END IF;
	RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER set_doc_auto_status AFTER UPDATE ON tasks
FOR EACH ROW EXECUTE PROCEDURE set_doc_auto_status();
