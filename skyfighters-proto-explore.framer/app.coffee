# Setup

cols = 4
rows = 20
if Utils.isMobile()
	dpiScale = 1
else
	dpiScale = 0.5
cardWidth = 300 * dpiScale
cardHeight = 200 * dpiScale
cardSpacing = (Screen.width - cols * cardWidth) / 5
selectedWidth = 700 * dpiScale
selectedHeight = 600 * dpiScale
selectedX = (Screen.width - (cardSpacing + 2 * selectedWidth)) / 2
selectedY = cardSpacing
poiWidth = 60 * dpiScale
poiHeight = 60 * dpiScale

Framer.Device.fullScreen = true
Framer.Defaults.Animation = {
    curve: "cubic-bezier"
    time: 0.22
}

bg = new BackgroundLayer
	backgroundColor: "#eee"

gridLayers = []
selectedLayers = []
pois = []

# Create map
map = new Layer
	width: Screen.width
	height: selectedHeight + 2 * cardSpacing
	x: 0
	y: 0
	backgroundColor: "transparent"
	scale: 1.2
	opacity: 0

map.visible = false

mapContent = new Layer
	width: 4000
	height: 4000
	superLayer: map
	backgroundColor: "transparent"
mapContent.draggable.enabled = true

# Navbar
navbar = new Layer
	width: 400 * dpiScale
	height: 90 * dpiScale
	y: 10
	backgroundColor: "white"
	borderRadius: 10
navbar.visible = false
navbar.shadowY = 10
navbar.shadowBlur = 20
navbar.shadowColor = "rgba(0,0,0,0.3)"
navbar.centerX()
navbar.html = "<div style='color: #03f; font-size: 36px; padding: 30px;'>&#8592; Back</div>"
navbar.on Events.Click, ->
	gridLayers[gridLayers.length - 1].visible = false
	gridLayers[gridLayers.length - 2].animate
		properties:
			scale: 1
			opacity: 1
			blur: 0

# Selected cards stack
selectedCardsStack = new Layer
	width: Screen.width / 2
	height: cardSpacing * 2 + selectedHeight
	backgroundColor: "transparent"


# Create a new grid layer
# -----------------------

makePOILayer = (id, fromX, fromY, fromWidth, fromHeight, fromColor) ->

	# Fade out previous layer and reveal map
	gridLayers[id - 1].animate
		properties:
			scale: 0.9
			opacity: 0
			blur: 80
	if id > 1
		gridLayers[id - 2].animate
			properties:
				scale: 0.8
				opacity: 0
		gridLayers[id - 2].on Events.AnimationEnd, ->
			gridLayers[id - 2].visible = false
	map.visible = true
	map.animate
		properties:
			scale: 1
			opacity: 1
			blur: 0


	# Create new canvas layer
	gridLayers[id] = new Layer
		width: Screen.width
		height: Screen.height
		backgroundColor: "transparent"
	
	gridLayers[id].scroll = true
	
	# Reveal navbar
	navbar.bringToFront()
	navbar.visible = true
	
	# Create a new selected card to fly to position later, and position it above clicked POI or card
	selectedLayers[selectedLayers.length] = new Layer
		width: fromWidth
		height: fromHeight
		x: fromX
		y: fromY
		backgroundColor: fromColor
	
	selected = selectedLayers[selectedLayers.length - 1]
	
	if fromWidth < cardWidth
		selected.borderRadius = poiWidth / 2        # round edges if coming from a POI on map
	
	selected.shadowY = 2
	selected.shadowBlur = 6
	selected.shadowColor = "rgba(0,0,0,0.2)"

	# Related cards container
	grid = new Layer
		width: Screen.width
		height: rows * (cardHeight + cardSpacing)
		y: Screen.height
		backgroundColor: "transparent"
		superLayer: gridLayers[id]

	# Create grid of related cards
	for row in [0..rows - 1]
		for col in [0..cols - 1]
			card = new Layer
				# size and position
				width: cardWidth
				height: cardHeight
				x: cardSpacing + col * (cardWidth + cardSpacing)
				y: row * (cardHeight + cardSpacing)
				superLayer: grid
				
				# format cards
				backgroundColor: Utils.randomColor()
				
			card.shadowY = 2
			card.shadowBlur = 6
			card.shadowColor = "rgba(0,0,0,0.2)"
			
			card.on Events.Click, ->
				this.visible = false
				# add POI to map for clicked card
				poi = new Layer
					width: poiWidth
					height: poiHeight
					x: Utils.randomNumber(0, mapContent.width)
					y: Utils.randomNumber(0, mapContent.height)
					superLayer: mapContent
					backgroundColor: this.backgroundColor
					borderRadius: poiWidth / 2
				# poi onclick event
				# - - -
				# center map on POI
				mapContent.animate
					properties:
						x: map.width / 2 - poi.x - poiWidth / 2
						y: map.height / 2 - poi.y - poiHeight / 2
					time: 0.4
				# create new canvas
				makePOILayer(
					gridLayers.length, 
					this.x, 
					-gridLayers[id].scrollY + grid.y + this.y, 
					this.width, 
					this.height, 
					this.backgroundColor
				)

	# Animate selected in position
	selected.bringToFront()
	selected.animate
		properties:
			x: selectedX
			y: selectedY
			width: selectedWidth
			height: selectedHeight
			borderRadius: 0
	
	# Add selected to stack when arrived in position
	selected.on Events.AnimationEnd, ->
		this.off Events.AnimationEnd
		this.superLayer = selectedCardsStack
				
	# Rotate a bit previous selected
	if selectedLayers.length > 1
		selectedLayers[selectedLayers.length - 2].animate
			properties:
				rotationZ: Utils.randomNumber(-7, 7)
			curve: "spring(200,20,5)"

	# Reveal related grid
	Utils.delay 0.5, ->
		grid.animate
			properties:
				y: selectedHeight + 2 * cardSpacing

	# Hide selected & map if scrolled
	gridLayers[id].on Events.Scroll, ->
		map.opacity = selectedCardsStack.opacity = Utils.modulate(gridLayers[id].scrollY, [0, cardSpacing * 2], [1, 0], true)
		map.blur    = selectedCardsStack.blur    = Utils.modulate(gridLayers[id].scrollY, [0, cardSpacing * 2], [0, 10], true)
#		if gridLayers[id].scrollY > 0
#			gridLayers[id].bringToFront()
			
	# Arrange layer order
	# ---


makeInspirationLayer = () ->
	gridLayers[0] = new Layer
		width: Screen.width
		height: Screen.height
		backgroundColor: "transparent"
	
	gridLayers[0].scroll = true

	# Related cards container
	grid = new Layer
		width: Screen.width
		height: rows * (cardHeight + cardSpacing)
		y: cardSpacing
		backgroundColor: "transparent"
		superLayer: gridLayers[0]
				
	# Create grid of related cards
	for row in [0..rows - 1]
		for col in [0..cols - 1]
			card = new Layer
				# size and position
				width: cardWidth
				height: cardHeight
				x: cardSpacing + col * (cardWidth + cardSpacing)
				y: row * (cardHeight + cardSpacing)
				superLayer: grid
				
				# format cards
				backgroundColor: Utils.randomColor()
				
			card.shadowY = 2
			card.shadowBlur = 6
			card.shadowColor = "rgba(0,0,0,0.2)"
			
			card.on Events.Click, ->
				this.visible = false
				# add POI to map for clicked card
				poi = new Layer
					width: poiWidth
					height: poiHeight
					x: Utils.randomNumber(0, mapContent.width)
					y: Utils.randomNumber(0, mapContent.height)
					superLayer: mapContent
					backgroundColor: this.backgroundColor
					borderRadius: poiWidth / 2
				# poi onclick event
				# - - -
				# center map on POI
				mapContent.animate
					properties:
						x: map.width / 2 - poi.x - poiWidth / 2
						y: map.height / 2 - poi.y - poiHeight / 2
					time: 0.4
				# create new canvas
				makePOILayer(
					gridLayers.length, 
					this.x, 
					-gridLayers[0].scrollY + grid.y + this.y, 
					this.width, 
					this.height, 
					this.backgroundColor
				)

			# create initial set of POIs on map
			poi = new Layer
				width: poiWidth
				height: poiHeight
				x: Utils.randomNumber(0, mapContent.width)
				y: Utils.randomNumber(0, mapContent.height)
				superLayer: mapContent
				backgroundColor: card.backgroundColor
				borderRadius: poiWidth / 2
			
			poi.on Events.Click, ->
				mapContent.animate
					properties:
						x: map.width / 2 - this.x - poiWidth / 2
						y: map.height / 2 - this.y - poiHeight / 2
					time: 0.4
				makePOILayer(
					gridLayers.length, 
					map.x + mapContent.x + this.x, 
					map.y + mapContent.y + this.y, 
					this.width, 
					this.height, 
					this.backgroundColor
				)


makeInspirationLayer()
