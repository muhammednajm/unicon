import express from 'express'

// import modules
import Document from './modules/document/document'
import Task from './modules/task/task'
import Execution from './modules/execution/execution'

const app = express()
const port = 4000

app.use(express.json())
app.use('/documents', Document)
app.use('/tasks', Task)
app.use('/executions', Execution)

app.listen(port, () => console.info(`server ready at ${port}`))
