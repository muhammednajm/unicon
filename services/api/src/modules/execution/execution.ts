import { Router, Request, Response } from 'express'
import * as model from './execution.model'

const router = Router()

router.get('/', async (req: Request, res: Response) => {

	const taskId = req.query.taskId as string

	res.send(await model.getMany(taskId))
})

router.put('/report', async (req: Request, res: Response) => {

	const { id, report } = req.body

	const userId = req.headers['user-id']

	if (!userId) {

		return res.status(401).end()
	}

	if (!report || !report.trim().length) {

		return res.status(400).end()
	}

	res.status(await model.setReport(id as string, userId as string, report)).end()
})

router.put('/status', async (req: Request, res: Response) => {

	const { id, status } = req.body

	const userId = req.headers['user-id']

	if (!userId) {

		return res.status(401).end()
	}

	res.status(await model.setExecutionStatus(id as string, status as string, parseInt(<string>(userId)))).end()
})

export default router
