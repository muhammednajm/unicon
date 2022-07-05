import { Pool } from 'pg'

const pool = new Pool({
	user: 'muhammad',
	host: 'localhost',
	database: 'unicon',
	password: 'math',
	port: 5432,
})

const rows = async (SQL: string, ...params: string[]) => {

	const client = await pool.connect()

	try {
		const { rows } = await client.query(SQL, params)
		return rows
	} catch(err) {
		console.error(err)
	} finally {
		client.release()
	}
}


const row = async (SQL: string, ...params: string[]) => {

	const client = await pool.connect()

	try {
		const { rows: [row] } = await client.query(SQL, params)
		return row
	} catch(err) {
		console.error(err)
	} finally {
		client.release()
	}
}

export {
	rows,
	row,
}
