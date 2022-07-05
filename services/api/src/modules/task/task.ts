import { Router, Request, Response } from 'express'
import * as model from './task.model'

const router = Router()

router.get('/', async (req: Request, res: Response) => {

	res.send(await model.getMany(<string>(req.query.documentId)))
})

export default router
