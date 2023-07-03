const express = require('express')
const path = require('path')
var mysql = require('mysql')

var connection = mysql.createConnection({
	host: process.env.RDS_HOSTNAME,
	port: process.env.RDS_PORT,
	user: process.env.RDS_USERNAME,
	password: process.env.RDS_PASSWORD,
	database: process.env.DB_NAME,
})

connection.connect(function (err) {
	if (!err) {
		console.log('Database is connected ... ')
	} else {
		console.log('Error connecting database ... ')
		console.log(err)
	}
})

const app = express()
const port = process.env.PORT || 80

// load static files
app.use(express.static('public'))

// query DB
app.get('/smashes', async (req, res) => {
	connection.query(
		'SELECT count(*) as smash_count FROM smashes',
		function (err, result) {
			if (err) throw err
			else {
				res.status(200).send(JSON.stringify(result[0].smash_count))
				console.log(`query result: ${JSON.stringify(result[0].smash_count)}`)
			}
			console.log(req)
		}
	)
})

// add a smash
app.post('/smash', async (req, res) => {
	connection.query(
		// insert an "empty" row
		// for demonstration purposes
		'INSERT INTO smashes VALUES()',
		function (err, result) {
			if (err) throw err
			else {
				res.status(200).send(JSON.stringify(result))
				console.log(JSON.stringify(result))
			}
		}
	)
})

// serve "homepage"
app.get('/', function (req, res) {
	res.sendFile(path.join(__dirname, 'index.html'))
})

app.listen(port)
console.log(`Server started at http://localhost:${port}`)
