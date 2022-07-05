INSERT INTO users (name) VALUES ('Umar'), ('Harun'), ('Aisha'), ('Hafsa');

-- Umar (Chancellery)
-- Harun (Document controller)
-- Aisha (Task executor)
-- Hafsa (Task executor)

INSERT INTO permissions (user_id, action) VALUES
(1, 10),
(2, 20),
(3, 30),
(4, 30)
;

INSERT INTO documents (name, user_id) VALUES
('Document X', 1),
('Document Y', 1)
;

INSERT INTO tasks (summary, expires_at, document_id, user_id) VALUES
('Task A', '2022-07-15'::timestamptz, 1, 2),
('Task B', '2022-07-20'::timestamptz, 1, 2)
;

INSERT INTO executors (user_id, task_id) VALUES
(3, 1),
(4, 1),
(4, 2)
;
