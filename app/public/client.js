const smashCountSpan = document.getElementById('smashCount')

async function fetchSmashCount() {
	const response = await fetch('/smashes', { method: 'GET' })
	smashCount = await response.json().then((parsedResponse) => {
		smashCountSpan.innerText = parsedResponse
		console.log(`smash count: ${parsedResponse}`)
	})
}

async function incrementSmashCount() {
	const response = await fetch('/smash', { method: 'POST' })
	smashCount = await response.json().then((parsedResponse) => {
		console.log('smash count incremented. request response:', parsedResponse)
	})
}

// fetch count on load
window.addEventListener('load', (event) => {
	fetchSmashCount()
})

const button = document.getElementById('increment')
button.addEventListener('click', function (e) {
	console.log('button be clicked')
	incrementSmashCount()
	fetchSmashCount()
})
