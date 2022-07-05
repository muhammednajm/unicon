import { Router, Response } from 'express'
import * as model from './document.model'

const router = Router()

router.get('/', async (_, res: Response) => {

	res.send(await model.getMany())
})

export default router
