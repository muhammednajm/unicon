-- get documents
SELECT
	ARRAY_AGG(
		JSON_BUILD_OBJECT(
			'id', d.id,
			'name', d.name,
			'status', CASE
				WHEN d.status = 0 THEN 'deleted'
				WHEN d.status = 1 THEN 'pending'
				WHEN d.status = 2 THEN 'closed'
			END,
			'createdAt', d.created_at,
			'owner', JSON_BUILD_OBJECT(
				'id', u.id,
				'name', u.name
			)
		)
	) AS data
FROM documents AS d
JOIN users AS u ON u.id = d.user_id;

-- get tasks
SELECT
	ARRAY_AGG(
		JSON_BUILD_OBJECT(
			'id', t.id,
			'summary', t.summary,
			'createdAt', t.created_at,
			'expiresAt', t.expires_at,
			'status', CASE
				WHEN t.expires_at > CURRENT_TIMESTAMP
				THEN CASE t.status
					WHEN 0 THEN 'deleted'
					WHEN 1 THEN 'pending'
					WHEN 2 THEN 'executed'
				END
				ELSE 'expired'
			END,
			'controller', JSON_BUILD_OBJECT(
				'id', u.id,
				'name', u.name
			)
		)
	) AS data
FROM tasks AS t
JOIN users AS u ON u.id = t.user_id
WHERE t.document_id = 1
;

-- get executors of task
SELECT
	ARRAY_AGG(
		JSON_BUILD_OBJECT(
			'id', e.id,
			'status', CASE e.status
				WHEN 0 THEN 'rejected'
				WHEN 1 THEN 'open'
				WHEN 2 THEN 'pending'
				WHEN 3 THEN 'resolved'
			END,
			'report', e.report,
			'executor', JSON_BUILD_OBJECT(
				'id', u.id,
				'name', u.name
			)
		)
	) AS data
FROM executors AS e
JOIN users AS u ON u.id = e.user_id
WHERE e.task_id = 1
;

