import { row } from '../../utils'

const getMany = async (taskId: string) => {

	const result = await row(`
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
		WHERE e.task_id = $1
	`, taskId)

	return result.data || []
}

const setReport = async (id: string, userId: string, report: string) => {

	const task = await row(`select * from executors where id = $1 and user_id = $2`, id, userId)

	if (!task) {
		return 401
	}

	await row(`update executors set report = $1 where id = $2`, report, id)

	return 200
}

const setExecutionStatus = async (id: string, status: string, userId: number) => {

	const control = await row(`select user_id from tasks where id = (
		select task_id from executors where id = $1
	)`, id)

	if (control.user_id !== userId) {
			return 401
	}

	await row(`update executors set status = $1 where id = $2`, status, id)

	return 200
}

export {
	getMany,
	setReport,
	setExecutionStatus,
}
