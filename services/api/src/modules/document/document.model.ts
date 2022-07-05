import { row } from '../../utils'

const getMany = async () => {

	const result = await row(`
		SELECT
			ARRAY_AGG(
				JSON_BUILD_OBJECT(
					'id', d.id,
					'name', d.name,
					'status', CASE d.status
						WHEN 0 THEN 'deleted'
						WHEN 1 THEN 'pending'
						WHEN 2 THEN 'closed'
					END,
					'createdAt', d.created_at,
					'owner', JSON_BUILD_OBJECT(
						'id', u.id,
						'name', u.name
					)
				)
			) AS data
		FROM documents AS d
		JOIN users AS u ON u.id = d.user_id
	`)

	return result.data || []
}

export {
	getMany,
}
