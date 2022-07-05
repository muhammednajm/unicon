import { row } from '../../utils'

const getMany = async (documentId: string) => {

	const result = await row(`
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
		WHERE t.document_id = $1
	`, documentId)

	return result.data || []
}

export {
	getMany,
}
