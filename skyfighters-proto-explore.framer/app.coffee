# Init multitouch event handling with Hammer 2
# --------------------------------------------
HammerEvents =
	Tap: "tap"
	DoubleTap: "doubletap"
	Hold: "hold"
	Touch: "touch"
	Release: "release"
	Gesture: "gesture"

	Swipe: "swipe"
	SwipeUp: "swipeup"
	SwipeDown: "swipedown"
	SwipeLeft: "swipeleft"
	SwipeRight: "swiperight"
	
	Transform: "transform"
	TransformStart: "transformstart"
	TransformEnd: "transformend"

	Rotate: "rotate"

	Pinch: "pinch"
	PinchIn: "pinchin"
	PinchOut: "pinchout"
	
	Drag: "drag"
	DragStart: "dragstart"
	DragEnd: "dragend"

window.Events = _.extend Events, HammerEvents

class HammerLayer extends Framer.Layer
	on: (eventName, f) ->
		if eventName in _.values(HammerEvents)
			@ignoreEvents = false
			hammer = Hammer(@_element).on eventName, f
		else
			super eventName, f

window.Layer = HammerLayer

# Enables a fake-Multitouch by holding the "Shift"-key
Hammer.plugins.fakeMultitouch()


# Setup & variables
# -----------------

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
	backgroundColor: "#f5f5f5"

# Create main layers to hold card grids
relatedCardsGrid = new Layer
	width: Screen.width
	height: Screen.height
	backgroundColor: "transparent"
relatedCardsGrid.scroll = true

selectedCards = []
pois = []

# Create map container
map = new Layer
	width: Screen.width
	height: selectedHeight + 2 * cardSpacing
	x: 0
	y: 0
	backgroundColor: "#F2EEE7"
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
navbar.html = "<div style='color: #ddd; font-size: 36px; padding: 30px;'>&#8592; Back</div>"

# Selected cards stack
selectedCardsStack = new Layer
	width: Screen.width / 2
	height: cardSpacing * 2 + selectedHeight
	backgroundColor: "transparent"

# Spread cardstack for history
selectedCardsStack.on Events.Pinch, ->
	#selectedCardsStack.scale = event.gesture.scale - 1
	#print event.gesture.scale


# Create a new grid layer
# -----------------------

makePOILayer = (fromX, fromY, fromWidth, fromHeight, fromColor) ->
	
	# Clone current grid for fade out animation
	relatedCardsGridPrevious = relatedCardsGrid.copy()
	relatedCardsGridPrevious.animate
		properties:
			scale: 0.9
			opacity: 0
			blur: 80
	relatedCardsGridPrevious.on Events.AnimationEnd, ->
		relatedCardsGridPrevious.visible = false
		relatedCardsGridPrevious.destroy()

	# Reveal map
	map.visible = true
	map.animate
		properties:
			scale: 1
			opacity: 1
			blur: 0

	# Reveal navbar
	navbar.visible = true
	
	# Create a new selected card to fly to position later, and position it above clicked POI or card
	selectedCards[selectedCards.length] = new Layer
		width: fromWidth
		height: fromHeight
		x: fromX
		y: fromY
		backgroundColor: fromColor
	
	selected = selectedCards[selectedCards.length - 1]
	
	if fromWidth < cardWidth
		selected.borderRadius = poiWidth / 2        # round edges if coming from a POI on map
	
	selected.shadowY = 2
	selected.shadowBlur = 6
	selected.shadowColor = "rgba(0,0,0,0.2)"

	# Delete previous grid of cards
	relatedCardsGrid.subLayers[0].destroy()

	# Create new grid for related cards
	grid = new Layer
		width: Screen.width
		height: rows * (cardHeight + cardSpacing)
		y: Screen.height
		backgroundColor: "transparent"
		superLayer: relatedCardsGrid

	# Populate grid with cards
	for row in [0..rows - 1]
		for col in [0..cols - 1]
			card = new Layer
				width: cardWidth
				height: cardHeight
				x: cardSpacing + col * (cardWidth + cardSpacing)
				y: row * (cardHeight + cardSpacing)
				superLayer: grid
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
				# center map on POI
				mapContent.animate
					properties:
						x: map.width / 4 * 3 - poi.x - poiWidth / 2
						y: map.height / 2 - poi.y - poiHeight / 2
					time: 0.4
				# create new canvas
				makePOILayer(
					this.x, 
					relatedCardsGrid.scrollY + grid.y + this.y, 
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
	if selectedCards.length > 1
		selectedCards[selectedCards.length - 2].animate
			properties:
				rotationZ: Utils.randomNumber(-5, 5)
			curve: "spring(800,80,0)"

	# Reveal related grid
	Utils.delay 0.5, ->
		grid.animate
			properties:
				y: selectedHeight + 2 * cardSpacing

	# Hide selected & map if scrolled
	relatedCardsGrid.on Events.Scroll, ->
		if this.scrollY > 0
			this.bringToFront()
			navbar.bringToFront()
		else
			map.bringToFront()
			selectedCardsStack.bringToFront()
			navbar.bringToFront()
		map.opacity = selectedCardsStack.opacity = Utils.modulate(relatedCardsGrid.scrollY, [0, cardSpacing * 2], [1, 0], true)
		map.blur    = selectedCardsStack.blur    = Utils.modulate(relatedCardsGrid.scrollY, [0, cardSpacing * 2], [0, 10], true)
		
		# rearrange layers when scrolled
		if relatedCardsGrid.scrollY > 0
			relatedCardsGrid.bringToFront()
			navbar.bringToFront()
		else
			map.bringToFront()
			selectedCardsStack.bringToFront()
			navbar.bringToFront()


# Create initial inspiration board
# --------------------------------

makeInspirationLayer = () ->

	# Related cards container
	grid = new Layer
		width: Screen.width
		height: rows * (cardHeight + cardSpacing)
		y: cardSpacing
		backgroundColor: "transparent"
		superLayer: relatedCardsGrid
				
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
				# center map on POI
				mapContent.animate
					properties:
						x: map.width / 4 * 3 - poi.x - poiWidth / 2
						y: map.height / 2 - poi.y - poiHeight / 2
					time: 0.4
				# create new canvas
				makePOILayer(
					this.x, 
					relatedCardsGrid.scrollY + grid.y + this.y, 
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
					map.x + mapContent.x + this.x, 
					map.y + mapContent.y + this.y, 
					this.width, 
					this.height, 
					this.backgroundColor
				)
	
	# Add fader at the bottom of map
	mapFader = new Layer
		width: map.width
		height: 200
		y: map.height - 200
		backgroundColor: "transparent"
		superLayer: map
		
	mapFader.image = "images/map_bottom_fader.png"
		

makeInspirationLayer()
